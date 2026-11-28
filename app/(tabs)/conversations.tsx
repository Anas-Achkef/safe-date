import { useCallback, useState } from 'react';
import { Image, Linking, Pressable, ScrollView, StyleSheet, Text, View } from 'react-native';

import { router, useFocusEffect } from 'expo-router';

import {
  answerRequest,
  listConversations,
  loadInbox,
  openRequest,
} from '../../src/api/conversations';
import { listUpcomingDates, revealEstablishment } from '../../src/api/dates';
import { Avatar } from '../../src/components/Avatar';
import { CarteRendezVous } from '../../src/components/CarteRendezVous';
import { Screen } from '../../src/components/Screen';
import { StateView } from '../../src/components/StateView';
import { usePosition } from '../../src/hooks/usePosition';
import { formaterChrono } from '../../src/lib/conversationLive';
import { isPreviewMode } from '../../src/preview';
import {
  distanceMetres,
  formaterMetres,
  SEUIL_REVELATION_M,
  type Coordonnees,
} from '../../src/lib/geo';
import { colors, hairline, opacity, radius, spacing, typography } from '../../src/theme';
import type {
  DateIntent,
  DemandeRecue,
  ResumeConversation,
  ResumeRendezVous,
} from '../../src/types/conversations';
import type { Establishment } from '../../src/types/rpc';

/**
 * Onglet « Discussions ».
 *
 * Une demande arrive fermee : on sait qui ecrit et a quel point le moteur
 * juge l'accord probable, rien de plus. L'ouvrir est un acte volontaire, et
 * c'est lui qui declenche le delai de reponse — d'ou l'absence de compte a
 * rebours tant qu'on n'a pas regarde.
 */

const LIBELLE_RENCONTRE: Record<string, string> = {
  amour: 'Amour',
  amitie: 'Amitié',
  fun: 'Fun',
};

/** Le serveur sert des secondes ; l'ecran en fait une duree lisible. */
function formaterDelai(secondes: number): string {
  if (secondes <= 0) return 'Expirée';
  const heures = Math.floor(secondes / 3600);
  if (heures >= 24) {
    const jours = Math.floor(heures / 24);
    return `${jours} j restant${jours > 1 ? 's' : ''}`;
  }
  if (heures >= 1) return `${heures} h restante${heures > 1 ? 's' : ''}`;
  const minutes = Math.max(1, Math.floor(secondes / 60));
  return `${minutes} min restante${minutes > 1 ? 's' : ''}`;
}

/** Ou en est la conversation, en une ligne. */
function sousTitre(f: ResumeConversation): string {
  if (f.illimitee) return f.dernier_message ?? 'Conversation ouverte';
  switch (f.statut) {
    case 'prete':
      return 'Votre conversation vous attend';
    case 'active':
      return f.secondes_restantes !== null
        ? `En cours · ${formaterChrono(f.secondes_restantes)}`
        : (f.dernier_message ?? 'En cours');
    case 'verrouillee':
      return 'Le temps est écoulé';
    case 'cloturee':
      return 'Conversation close';
  }
}

export default function Discussions() {
  const [demandes, setDemandes] = useState<DemandeRecue[]>([]);
  const [fils, setFils] = useState<ResumeConversation[]>([]);
  const [rdv, setRdv] = useState<ResumeRendezVous[]>([]);
  /** Segment affiche. Les trois moitiés de l'onglet ne se mélangent pas. */
  const [segment, setSegment] = useState<'conversations' | 'demandes' | 'rdv'>('conversations');
  const [chargement, setChargement] = useState(true);
  const [erreur, setErreur] = useState<string | null>(null);
  /** Identifiant de la demande dont une action est en cours. */
  const [enCours, setEnCours] = useState<string | null>(null);

  const charger = useCallback(async () => {
    try {
      setErreur(null);
      const [boite, conversations, dates] = await Promise.all([
        loadInbox(),
        listConversations(),
        listUpcomingDates(),
      ]);
      setDemandes(boite);
      setFils(conversations);
      setRdv(dates);
    } catch (e) {
      setErreur((e as Error).message);
    } finally {
      setChargement(false);
    }
  }, []);

  // Au retour d'une conversation, la liste doit montrer son nouvel etat.
  useFocusEffect(
    useCallback(() => {
      void charger();
    }, [charger]),
  );

  const ouvrir = useCallback(
    async (demande: DemandeRecue) => {
      if (enCours) return;
      setEnCours(demande.demande_id);
      try {
        await openRequest(demande.demande_id);
        // Le delai vient de demarrer cote serveur : on relit plutot que de
        // deviner la valeur du compte a rebours.
        await charger();
      } catch (e) {
        setErreur((e as Error).message);
      } finally {
        setEnCours(null);
      }
    },
    [charger, enCours],
  );

  const repondre = useCallback(
    async (demande: DemandeRecue, reponse: DateIntent) => {
      if (enCours) return;
      setEnCours(demande.demande_id);
      try {
        await answerRequest(demande.demande_id, reponse);
        await charger();
      } catch (e) {
        setErreur((e as Error).message);
      } finally {
        setEnCours(null);
      }
    },
    [charger, enCours],
  );

  if (chargement) {
    return (
      <Screen title="Discussions">
        <StateView variant="loading" title="Chargement" />
      </Screen>
    );
  }

  if (erreur) {
    return (
      <Screen title="Discussions">
        <StateView
          variant="error"
          title="Impossible de charger"
          message={erreur}
          actionLabel="Réessayer"
          onAction={() => void charger()}
        />
      </Screen>
    );
  }

  if (demandes.length === 0 && fils.length === 0 && rdv.length === 0) {
    return (
      <Screen title="Discussions">
        <StateView
          variant="empty"
          title="Aucune demande"
          message="Les demandes reçues apparaissent ici. Personne ne peut vous écrire sans que vous ayez accepté."
        />
      </Screen>
    );
  }

  return (
    <Screen title="Discussions">
      <View style={styles.segments}>
        {([
          ['conversations', 'Messages', fils.length],
          ['demandes', 'Demandes', demandes.length],
          ['rdv', 'Rendez-vous', rdv.length],
        ] as const).map(([cle, libelle, nombre]) => (
          <Pressable
            key={cle}
            onPress={() => setSegment(cle)}
            style={[styles.segment, segment === cle && styles.segmentActif]}
          >
            <Text
              numberOfLines={1}
              allowFontScaling={false}
              style={[styles.segmentTexte, segment === cle && styles.segmentTexteActif]}
            >
              {libelle}
            </Text>
            {nombre > 0 ? (
              <View style={[styles.segmentPastille, segment === cle && styles.segmentPastilleActive]}>
                <Text
                  allowFontScaling={false}
                  style={[styles.segmentNombre, segment === cle && styles.segmentNombreActif]}
                >
                  {nombre}
                </Text>
              </View>
            ) : null}
          </Pressable>
        ))}
      </View>

      <ScrollView contentContainerStyle={styles.liste} showsVerticalScrollIndicator={false}>
        {segment === 'rdv' ? <ListeRendezVous rdv={rdv} /> : null}

        {segment === 'conversations' && fils.length > 0 ? (
          <View style={styles.section}>
            <Text style={styles.sectionTitre}>CONVERSATIONS</Text>
            {fils.map((f) => (
              <Pressable
                key={f.conversation_id}
                style={styles.fil}
                onPress={() => router.push(`/conversation/${f.conversation_id}`)}
              >
                <Avatar seed={f.autre} firstName={f.prenom_autre} photo={f.photo_autre} size={52} rounded="pill" />
                <View style={styles.filTexte}>
                  <View style={styles.filHaut}>
                    <Text style={styles.filPrenom} numberOfLines={1}>
                      {f.prenom_autre}
                      {f.age_autre ? <Text style={styles.filAge}>, {f.age_autre}</Text> : null}
                    </Text>
                    {f.autre_en_ligne ? <View style={styles.enLigne} /> : null}
                  </View>
                  <Text style={styles.filApercu} numberOfLines={1}>
                    {sousTitre(f)}
                  </Text>
                </View>
              </Pressable>
            ))}
          </View>
        ) : null}

        {segment === 'demandes' &&
          demandes.map((d) => {
          // Une demande non ouverte n'a pas de delai : c'est ce qui distingue
          // les deux etats de la carte.
          const ouverte = d.secondes_restantes !== null;
          const occupe = enCours === d.demande_id;

          return (
            <View key={d.demande_id} style={styles.carte}>
              <View style={styles.entete}>
                {d.photo_principale ? (
                  <Image source={{ uri: d.photo_principale }} style={styles.photo} />
                ) : (
                  <View style={[styles.photo, styles.photoAbsente]} />
                )}

                <View style={styles.identite}>
                  <Text style={styles.prenom} numberOfLines={1}>
                    {d.prenom}
                    {d.age ? <Text style={styles.age}>, {d.age}</Text> : null}
                  </Text>

                  <View style={styles.meta}>
                    <View style={styles.pastille}>
                      <Text style={styles.pastilleTexte}>
                        {LIBELLE_RENCONTRE[d.type_rencontre] ?? d.type_rencontre}
                      </Text>
                    </View>
                    {d.distance ? <Text style={styles.metaTexte}>{d.distance}</Text> : null}
                    {d.profil_verifie ? <Text style={styles.metaTexte}>Profil vérifié</Text> : null}
                  </View>
                </View>

                {d.compat_rate !== null ? (
                  <View style={styles.score}>
                    <Text style={styles.scoreValeur}>{Math.round(d.compat_rate)}</Text>
                    <Text style={styles.scoreUnite}>%</Text>
                  </View>
                ) : null}
              </View>

              {ouverte ? (
                <>
                  <Text style={styles.delai}>{formaterDelai(d.secondes_restantes ?? 0)}</Text>
                  <View style={styles.actions}>
                    <Pressable
                      style={[styles.action, styles.actionOui, occupe && styles.actionOccupe]}
                      onPress={() => void repondre(d, 'oui')}
                      disabled={occupe}
                    >
                      <Text style={[styles.actionTexte, styles.actionTexteOui]}>Accepter</Text>
                    </Pressable>

                    {d.reportable ? (
                      <Pressable
                        style={[styles.action, styles.actionNeutre, occupe && styles.actionOccupe]}
                        onPress={() => void repondre(d, 'plus_tard')}
                        disabled={occupe}
                      >
                        <Text style={styles.actionTexte}>Plus tard</Text>
                      </Pressable>
                    ) : null}

                    <Pressable
                      style={[styles.action, styles.actionNeutre, occupe && styles.actionOccupe]}
                      onPress={() => void repondre(d, 'non')}
                      disabled={occupe}
                    >
                      <Text style={[styles.actionTexte, styles.actionTexteNon]}>Refuser</Text>
                    </Pressable>
                  </View>
                </>
              ) : (
                <Pressable
                  style={[styles.decouvrir, occupe && styles.actionOccupe]}
                  onPress={() => void ouvrir(d)}
                  disabled={occupe}
                >
                  <Text style={styles.decouvrirTexte}>Découvrir</Text>
                </Pressable>
              )}
            </View>
          );
        })}
      </ScrollView>
    </Screen>
  );
}

/** Date et heure du creneau, en francais et sans dependance externe. */
function creneau(iso: string): string {
  const d = new Date(iso);
  const jours = ['dimanche', 'lundi', 'mardi', 'mercredi', 'jeudi', 'vendredi', 'samedi'];
  const heure = `${d.getHours()}h${String(d.getMinutes()).padStart(2, '0')}`;
  const dans = Math.round((d.getTime() - Date.now()) / 3_600_000);
  if (dans < 24) return `Aujourd’hui ${heure}`;
  if (dans < 48) return `Demain ${heure}`;
  return `${jours[d.getDay()]} ${heure}`;
}

const LIBELLE_STATUT: Record<string, string> = {
  en_preparation: 'En préparation',
  confirme: 'Confirmé',
  en_cours: 'En cours',
};

/**
 * Les rendez-vous a venir.
 *
 * L'adresse n'apparait jamais : elle ne se devoile qu'a moins de vingt-cinq
 * metres du point de rencontre. La carte montre la ville et le creneau, et
 * c'est deliberement tout.
 */
function ListeRendezVous({ rdv }: { rdv: ResumeRendezVous[] }) {
  // Un seul suivi de position pour toute la liste : plusieurs abonnements
  // reveilleraient le capteur en double sans rien apporter.
  const { etat, position, precision, demander } = usePosition();

  if (rdv.length === 0) {
    return (
      <View style={styles.vide}>
        <Text style={styles.videTexte}>
          Aucun rendez-vous prévu. Ils apparaissent ici une fois la date convenue.
        </Text>
      </View>
    );
  }

  return (
    <View style={styles.section}>
      {rdv.map((r) => (
        <CarteRdv
          key={r.date_id}
          rdv={r}
          moi={position}
          etat={etat}
          precision={precision}
          demander={demander}
        />
      ))}
    </View>
  );
}

interface CarteRdvProps {
  rdv: ResumeRendezVous;
  moi: Coordonnees | null;
  etat: ReturnType<typeof usePosition>['etat'];
  precision: number | null;
  demander: () => Promise<void>;
}

/**
 * Une carte de rendez-vous.
 *
 * Elle ne nomme jamais l'etablissement : elle guide vers un point. Le nom et
 * l'adresse n'apparaissent qu'apres un appel a `reveal_establishment` reussi,
 * c'est-a-dire une fois sur place.
 */
function CarteRdv({ rdv: r, moi, etat, precision, demander }: CarteRdvProps) {
  const [lieu, setLieu] = useState<Establishment | null>(null);
  const [revelation, setRevelation] = useState<'inactif' | 'encours' | 'refus'>('inactif');
  const [simule, setSimule] = useState<Coordonnees | null>(null);

  // En demonstration seulement : le point est a Geneve, on ne peut pas
  // demander a un client de s'y rendre pour voir le mecanisme fonctionner.
  // `isPreviewMode` retombe a faux des que EXPO_PUBLIC_PREVIEW quitte le .env,
  // et ce bloc disparait avec lui.
  const maPosition = simule ?? moi;

  const point: Coordonnees | null =
    r.point_lat !== null && r.point_lon !== null
      ? { lat: r.point_lat, lon: r.point_lon }
      : null;

  // La distance mesuree prime sur celle transmise : elle vit, l'autre non.
  const distance =
    point && maPosition ? distanceMetres(maPosition, point) : (r.distance_m ?? null);

  // Le capteur peut annoncer vingt metres avec quarante d'incertitude : on ne
  // propose la revelation que si elle a une chance d'aboutir cote serveur.
  const aPortee =
    distance !== null && maPosition !== null && distance <= SEUIL_REVELATION_M;

  const reveler = async () => {
    if (!point || !maPosition) return;
    setRevelation('encours');
    try {
      const etablissement = await revealEstablishment(
        r.date_id,
        maPosition.lon,
        maPosition.lat,
      );
      setLieu(etablissement);
      setRevelation(etablissement ? 'inactif' : 'refus');
    } catch {
      // Le serveur refuse tant qu'on est trop loin : ce n'est pas une panne.
      setRevelation('refus');
    }
  };

  return (
    <View style={styles.carteRdv}>
      <View style={styles.rdvHaut}>
        <Avatar seed={r.autre} firstName={r.prenom_autre} photo={r.photo_autre} size={52} rounded="pill" />
        <View style={styles.rdvTexte}>
          <Text style={styles.rdvPrenom} numberOfLines={1}>
            {r.prenom_autre}
            {r.age_autre ? <Text style={styles.filAge}>, {r.age_autre}</Text> : null}
          </Text>
          <Text style={styles.rdvQuand}>{creneau(r.creneau_debut)}</Text>
        </View>
        <View style={styles.rdvStatut}>
          <Text style={styles.rdvStatutTexte} allowFontScaling={false}>
            {LIBELLE_STATUT[r.statut] ?? r.statut}
          </Text>
        </View>
      </View>

      {point ? (
        <View style={styles.point}>
          <CarteRendezVous point={point} moi={maPosition} style={styles.pointCarte} />

          <View style={styles.pointLigne}>
            <Text style={styles.pointTitre}>POINT DE RENCONTRE</Text>
            <Text style={[styles.pointDistance, aPortee && styles.pointDistanceProche]}>
              {formaterMetres(distance)}
            </Text>
          </View>

          <Text style={styles.pointCoords}>
            {r.ville ? `${r.ville} · ` : ''}
            {point.lat.toFixed(4)}, {point.lon.toFixed(4)}
            {simule
              ? ' · position simulée'
              : etat === 'active' && precision !== null
                ? ` · précision ${Math.round(precision)} m`
                : ''}
          </Text>

          {lieu ? (
            <View style={styles.lieu}>
              <Text style={styles.lieuNom}>{lieu.nom}</Text>
              <Text style={styles.lieuAdresse}>
                {lieu.adresse} · {lieu.code_postal} {lieu.ville}
              </Text>
            </View>
          ) : (
            <Text style={styles.pointNote}>
              {etat === 'refusee'
                ? "Position refusée : la distance ne peut pas être mesurée. L’adresse se débloque sur place, en réactivant la localisation dans les réglages."
                : etat === 'indisponible'
                  ? "Localisation indisponible sur cet appareil. L’adresse se débloque sur place."
                  : "Rendez-vous à ce point. L’adresse de l’établissement s’affiche une fois sur place."}
            </Text>
          )}

          {revelation === 'refus' ? (
            <Text style={styles.pointRefus}>
              Encore trop loin du point pour débloquer l’adresse.
            </Text>
          ) : null}

          <View style={styles.pointActions}>
            {etat === 'inactif' || etat === 'demande' ? (
              <Pressable
                style={({ pressed }) => [styles.pointAction, pressed && styles.presse]}
                onPress={() => void demander()}
              >
                <Text style={styles.pointActionTexte} allowFontScaling={false}>
                  {etat === 'demande' ? 'Localisation…' : 'Activer ma position'}
                </Text>
              </Pressable>
            ) : null}

            {aPortee && !lieu ? (
              <Pressable
                style={({ pressed }) => [styles.pointAction, pressed && styles.presse]}
                onPress={() => void reveler()}
              >
                <Text style={styles.pointActionTexte} allowFontScaling={false}>
                  {revelation === 'encours' ? 'Révélation…' : 'Révéler le lieu'}
                </Text>
              </Pressable>
            ) : null}

            <Pressable
              style={({ pressed }) => [styles.pointActionDoux, pressed && styles.presse]}
              onPress={() =>
                void Linking.openURL(
                  `https://www.google.com/maps/dir/?api=1&destination=${point.lat},${point.lon}`,
                )
              }
            >
              <Text style={styles.pointActionDouxTexte} allowFontScaling={false}>
                M’y rendre
              </Text>
            </Pressable>
          </View>

          {isPreviewMode ? (
            <Pressable
              onPress={() =>
                setSimule(simule ? null : { lat: point.lat + 0.00008, lon: point.lon })
              }
            >
              <Text style={styles.pointDemo}>
                {simule ? 'Démo · revenir à ma position' : 'Démo · simuler l’arrivée sur place'}
              </Text>
            </Pressable>
          ) : null}
        </View>
      ) : (
        <View style={styles.point}>
          <Text style={styles.pointNote}>
            Le point de rencontre sera communiqué avant le rendez-vous.
          </Text>
        </View>
      )}
    </View>
  );
}


const styles = StyleSheet.create({
  segments: {
    flexDirection: 'row',
    gap: spacing.xs,
    paddingBottom: spacing.md,
  },
  segment: {
    // Chacun prend un tiers : les libelles ne decident plus de la largeur, et
    // le troisieme ne peut plus sortir du cadre.
    flex: 1,
    flexDirection: 'row',
    alignItems: 'center',
    justifyContent: 'center',
    gap: spacing.xs,
    paddingHorizontal: spacing.xs,
    paddingVertical: spacing.sm,
    borderRadius: radius.pill,
    backgroundColor: colors.surfaceAlt,
  },
  segmentActif: { backgroundColor: colors.accent },
  segmentTexte: { ...typography.caption, color: colors.textSecondary, flexShrink: 1 },
  segmentTexteActif: { color: colors.onAccent },
  segmentPastille: {
    minWidth: 18,
    borderRadius: radius.pill,
    paddingHorizontal: spacing.xs,
    backgroundColor: colors.surface,
    alignItems: 'center',
  },
  segmentPastilleActive: { backgroundColor: colors.surfaceTranslucide },
  segmentNombre: { ...typography.caption, color: colors.textPrimary },
  segmentNombreActif: { color: colors.textPrimary },

  vide: { paddingVertical: spacing.xxxl },
  videTexte: { ...typography.body, color: colors.textMuted, textAlign: 'center' },

  carteRdv: {
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    padding: spacing.lg,
    gap: spacing.lg,
  },
  rdvHaut: { flexDirection: 'row', alignItems: 'center', gap: spacing.md },
  point: {
    backgroundColor: colors.surfaceAlt,
    borderRadius: radius.sm,
    padding: spacing.lg,
    gap: spacing.sm,
  },
  pointLigne: { flexDirection: 'row', justifyContent: 'space-between', alignItems: 'baseline' },
  pointTitre: { ...typography.overline, color: colors.textMuted },
  pointDistance: { ...typography.label, color: colors.accent },
  pointCoords: { ...typography.body, color: colors.textPrimary },
  pointNote: { ...typography.caption, color: colors.textMuted },
  pointCarte: { marginBottom: spacing.xs },
  pointDistanceProche: { color: colors.textPrimary },
  pointRefus: { ...typography.caption, color: colors.danger },
  pointDemo: {
    ...typography.caption,
    color: colors.textMuted,
    textAlign: 'center',
    textDecorationLine: 'underline',
  },
  lieu: {
    backgroundColor: colors.accentSoft,
    borderRadius: radius.sm,
    padding: spacing.md,
    gap: spacing.xs,
  },
  lieuNom: { ...typography.heading, color: colors.accent },
  lieuAdresse: { ...typography.caption, color: colors.textSecondary },
  pointActions: { flexDirection: 'row', gap: spacing.sm, marginTop: spacing.xs },
  pointAction: {
    flex: 1,
    backgroundColor: colors.accent,
    borderRadius: radius.pill,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.sm,
    alignItems: 'center',
    justifyContent: 'center',
  },
  pointActionTexte: { ...typography.label, color: colors.onAccent },
  pointActionDoux: {
    flex: 1,
    borderRadius: radius.pill,
    borderWidth: hairline,
    borderColor: colors.rule,
    paddingVertical: spacing.md,
    paddingHorizontal: spacing.sm,
    alignItems: 'center',
    justifyContent: 'center',
  },
  pointActionDouxTexte: { ...typography.label, color: colors.textSecondary },
  presse: { opacity: opacity.pressed },
  rdvTexte: { flex: 1, gap: spacing.xs },
  rdvPrenom: { ...typography.heading, color: colors.textPrimary },
  rdvQuand: { ...typography.label, color: colors.accent },
  rdvLieu: { ...typography.caption, color: colors.textMuted },
  rdvStatut: {
    backgroundColor: colors.accentSoft,
    borderRadius: radius.pill,
    paddingHorizontal: spacing.md,
    paddingVertical: spacing.xs,
  },
  rdvStatutTexte: { ...typography.caption, color: colors.accent },

  section: { gap: spacing.sm },
  sectionTitre: { ...typography.overline, color: colors.textMuted, marginBottom: spacing.xs },
  fil: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
    backgroundColor: colors.surface,
    borderRadius: radius.md,
    padding: spacing.lg,
  },
  filTexte: { flex: 1, gap: spacing.xs },
  filHaut: { flexDirection: 'row', alignItems: 'center', gap: spacing.sm },
  filPrenom: { ...typography.heading, color: colors.textPrimary, flexShrink: 1 },
  filAge: { ...typography.body, color: colors.textMuted },
  enLigne: { width: 8, height: 8, borderRadius: radius.pill, backgroundColor: colors.accent },
  filApercu: { ...typography.caption, color: colors.textSecondary },

  liste: {
    paddingHorizontal: spacing.lg,
    paddingBottom: spacing.xl,
    gap: spacing.md,
  },
  carte: {
    backgroundColor: colors.surface,
    borderRadius: radius.lg,
    borderWidth: hairline,
    borderColor: colors.rule,
    padding: spacing.md,
    gap: spacing.md,
  },
  entete: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.md,
  },
  photo: {
    width: 56,
    height: 56,
    borderRadius: radius.pill,
  },
  photoAbsente: {
    backgroundColor: colors.surfaceAlt,
  },
  identite: {
    flex: 1,
    gap: spacing.xs,
  },
  prenom: {
    ...typography.heading,
    color: colors.textPrimary,
  },
  age: {
    ...typography.body,
    color: colors.textSecondary,
  },
  meta: {
    flexDirection: 'row',
    alignItems: 'center',
    gap: spacing.sm,
  },
  pastille: {
    backgroundColor: colors.accentSoft,
    borderRadius: radius.pill,
    paddingHorizontal: spacing.sm,
    paddingVertical: 2,
  },
  pastilleTexte: {
    ...typography.overline,
    color: colors.accent,
  },
  metaTexte: {
    ...typography.caption,
    color: colors.textMuted,
  },
  score: {
    flexDirection: 'row',
    alignItems: 'baseline',
  },
  scoreValeur: {
    ...typography.subscoreValue,
    color: colors.textPrimary,
  },
  scoreUnite: {
    ...typography.caption,
    color: colors.textMuted,
  },
  delai: {
    ...typography.caption,
    color: colors.textMuted,
  },
  actions: {
    flexDirection: 'row',
    gap: spacing.sm,
  },
  action: {
    flex: 1,
    borderRadius: radius.pill,
    paddingVertical: spacing.sm,
    alignItems: 'center',
  },
  actionOui: {
    backgroundColor: colors.accent,
  },
  actionNeutre: {
    borderWidth: hairline,
    borderColor: colors.rule,
  },
  actionOccupe: {
    opacity: 0.5,
  },
  actionTexte: {
    ...typography.label,
    color: colors.textSecondary,
  },
  actionTexteOui: {
    color: colors.onAccent,
  },
  actionTexteNon: {
    color: colors.danger,
  },
  decouvrir: {
    borderRadius: radius.pill,
    borderWidth: hairline,
    borderColor: colors.rule,
    paddingVertical: spacing.sm,
    alignItems: 'center',
  },
  decouvrirTexte: {
    ...typography.label,
    color: colors.textPrimary,
  },
});
