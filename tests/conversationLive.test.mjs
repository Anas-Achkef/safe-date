import test from 'node:test';
import assert from 'node:assert/strict';
import {
  etapeDe,
  formaterChrono,
  fusionnerMessages,
  intervalleRafraichissement,
  restantSecondes,
  INTERVALLE_PRESENCE_MS,
  decompteDepuisServeur,
} from '../src/lib/conversationLive.ts';

const base = { statut: 'active', illimitee: false, restant: 120, decompteJusqua: null, decisionEnvoyee: false };

test('formaterChrono', () => {
  assert.equal(formaterChrono(300), '5:00');
  assert.equal(formaterChrono(245), '4:05');
  assert.equal(formaterChrono(9), '0:09');
  assert.equal(formaterChrono(0), '0:00');
});

test('restantSecondes décompte depuis la dernière lecture serveur', () => {
  assert.equal(restantSecondes(null, 0, 5_000), null);
  assert.equal(restantSecondes(120, 1_000, 1_999), 120);
  assert.equal(restantSecondes(120, 1_000, 11_000), 110);
  assert.equal(restantSecondes(5, 0, 60_000), 0);
});

test('intervalles', () => {
  assert.equal(INTERVALLE_PRESENCE_MS, 15_000);
  assert.equal(intervalleRafraichissement('active'), 3_000);
  assert.equal(intervalleRafraichissement('prete'), 10_000);
  assert.equal(intervalleRafraichissement('verrouillee'), 10_000);
});

test('etapeDe', () => {
  assert.equal(etapeDe({ ...base, statut: 'prete', restant: null }, 0), 'attente');
  assert.equal(etapeDe({ ...base, decompteJusqua: 3_000 }, 1_000), 'decompte');
  assert.equal(etapeDe({ ...base, decompteJusqua: 3_000 }, 3_000), 'active');
  assert.equal(etapeDe(base, 0), 'active');
  // Le serveur verrouille jusqu'à 60 s après la fin : on n'attend pas son statut.
  assert.equal(etapeDe({ ...base, restant: 0 }, 0), 'temps_ecoule');
  assert.equal(etapeDe({ ...base, statut: 'verrouillee', restant: null }, 0), 'temps_ecoule');
  assert.equal(
    etapeDe({ ...base, statut: 'verrouillee', restant: null, decisionEnvoyee: true }, 0),
    'decision_envoyee',
  );
  assert.equal(etapeDe({ ...base, illimitee: true, restant: null }, 0), 'illimitee');
  assert.equal(etapeDe({ ...base, statut: 'cloturee', restant: null }, 0), 'close');
});

test('fusionnerMessages dédoublonne et trie', () => {
  const m = (id, t) => ({
    id, conversation_id: 'c', sender_id: 's', kind: 'texte', body: id,
    audio_path: null, duration_ms: null, created_at: t,
  });
  const a = [m('1', '2026-11-28T10:00:00Z'), m('2', '2026-11-28T10:00:01Z')];
  assert.deepEqual(fusionnerMessages(a, []), a);
  const r = fusionnerMessages(a, [
    m('2', '2026-11-28T10:00:01Z'),
    m('3', '2026-11-28T10:00:02Z'),
    m('0', '2026-11-28T09:59:59Z'),
  ]);
  assert.deepEqual(r.map((x) => x.id), ['0', '1', '2', '3']);
});

test('restantSecondes ignore une lecture plus récente que l’horloge d’affichage (I-3)', () => {
  // Entre la lecture et le tic suivant, maintenant < recuA : le chrono ne doit pas remonter.
  assert.equal(restantSecondes(120, 5_000, 4_000), 120);
});

test('intervalleRafraichissement accélère quand l’autre est là (I-1)', () => {
  assert.equal(intervalleRafraichissement('prete', true), 3_000);
  assert.equal(intervalleRafraichissement('prete', false), 10_000);
  assert.equal(intervalleRafraichissement('active', false), 3_000);
});

test('decompteDepuisServeur : les deux voient le même 3, 2, 1 (I-1)', () => {
  // Le serveur fait partir les 5 minutes 3 s après le démarrage : 303 s restantes.
  assert.equal(decompteDepuisServeur(303, 10_000), 13_000);
  assert.equal(decompteDepuisServeur(301, 10_000), 11_000);
  assert.equal(decompteDepuisServeur(300, 10_000), null);
  assert.equal(decompteDepuisServeur(120, 10_000), null);
  assert.equal(decompteDepuisServeur(null, 10_000), null);
});
