--
-- PostgreSQL database dump
--

\restrict oQI5XYFRFsKA58tVqnSY9yGFuyWx5ktpLOOHcbzIcXVrhxuoEklneuLiRAKxzkB

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.10 (Homebrew)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Data for Name: profiles; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profiles (id, created_at, birth_date, age_min, age_max, search_radius_km, last_location, is_verified, is_active, langue, pays, geoloc_precise, systeme_unites, is_premium, prenom, always_available, notify_when_offline, intentions, last_seen_at) FROM stdin;
d0000000-0000-4000-8000-000000000001	2026-07-31 22:40:28.317884+00	1992-04-18	18	99	25	\N	t	t	fr	CH	\N	metrique	f	Camille	f	f	{amour}	\N
d0000000-0000-4000-8000-000000000003	2026-07-31 22:40:28.317884+00	1995-01-27	18	99	25	\N	t	t	fr	CH	\N	metrique	f	Inès	f	f	{amour}	\N
d0000000-0000-4000-8000-00000000000a	2026-08-01 16:48:35.217982+00	1994-06-15	18	99	25	\N	t	t	fr	CH	\N	metrique	f	Alex	f	f	{amour}	\N
d0000000-0000-4000-8000-000000000002	2026-07-31 22:40:28.317884+00	1997-09-02	18	99	25	\N	t	t	fr	FR	\N	metrique	f	Théo	f	f	{amour}	\N
\.


--
-- Data for Name: availability_windows; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.availability_windows (id, user_id, debut, fin, created_at) FROM stdin;
\.


--
-- Data for Name: blocks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.blocks (blocker_id, blocked_id, created_at) FROM stdin;
\.


--
-- Data for Name: chat_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.chat_requests (id, from_user, to_user, compat_rate, status, created_at, expires_at, responded_at, type_rencontre, opened_at, stale_at, postponed_at, postpone_count, ecran_ordre) FROM stdin;
\.


--
-- Data for Name: policy_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.policy_documents (code, version, published_at, body, body_sha256, is_current) FROM stdin;
cgu	0.1-demo	2026-07-31 22:40:28.317884+00	Texte provisoire de demonstration.	2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea	t
confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	Texte provisoire de demonstration.	2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea	t
donnees_personnelles	0.1-demo	2026-07-31 22:40:28.317884+00	Texte provisoire de demonstration.	2a97516c354b68848cdbd8f54a226a0a55b21ed138e207ad6c5cbb9c00aa5aea	t
\.


--
-- Data for Name: consents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.consents (user_id, category, policy_code, policy_version, granted_at, withdrawn_at, ip_address, user_agent) FROM stdin;
d0000000-0000-4000-8000-000000000001	sante	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000002	sante	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000003	sante	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000001	convictions_religieuses	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000002	convictions_religieuses	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000003	convictions_religieuses	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000001	opinions_politiques	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000002	opinions_politiques	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000003	opinions_politiques	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000001	identite_genre	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000002	identite_genre	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000003	identite_genre	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000001	orientation_sexuelle	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000002	orientation_sexuelle	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000003	orientation_sexuelle	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000001	origine_ethnique	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000002	origine_ethnique	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-000000000003	origine_ethnique	confidentialite	0.1-demo	2026-07-31 22:40:28.317884+00	\N	\N	\N
d0000000-0000-4000-8000-00000000000a	sante	confidentialite	0.1-demo	2026-08-01 16:48:35.217982+00	\N	\N	\N
d0000000-0000-4000-8000-00000000000a	convictions_religieuses	confidentialite	0.1-demo	2026-08-01 16:48:35.217982+00	\N	\N	\N
d0000000-0000-4000-8000-00000000000a	opinions_politiques	confidentialite	0.1-demo	2026-08-01 16:48:35.217982+00	\N	\N	\N
d0000000-0000-4000-8000-00000000000a	identite_genre	confidentialite	0.1-demo	2026-08-01 16:48:35.217982+00	\N	\N	\N
d0000000-0000-4000-8000-00000000000a	orientation_sexuelle	confidentialite	0.1-demo	2026-08-01 16:48:35.217982+00	\N	\N	\N
d0000000-0000-4000-8000-00000000000a	origine_ethnique	confidentialite	0.1-demo	2026-08-01 16:48:35.217982+00	\N	\N	\N
\.


--
-- Data for Name: context_weight_defaults; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.context_weight_defaults (type_rencontre, poids_physique, poids_mode_vie, poids_valeurs, seuil_exigence) FROM stdin;
amour	0.300	0.300	0.400	0.700
fun	0.600	0.100	0.300	0.550
amitie	0.150	0.450	0.400	0.600
\.


--
-- Data for Name: conversations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.conversations (id, request_id, user_a, user_b, started_at, ends_at, locked_at, status, illimitee, prete_at, presence_a_at, presence_b_at) FROM stdin;
\.


--
-- Data for Name: conversation_decisions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.conversation_decisions (conversation_id, user_id, decision, decided_at) FROM stdin;
\.


--
-- Data for Name: criteria; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.criteria (key, ord, moment, category, subcategory, cluster, direction, pair_key, question, multi_select, sensitive_category) FROM stdin;
animaux_moi	153	quiz	MODE VIE	Animaux	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	animaux	Avec les animaux, je :	f	\N
animaux_rech	154	quiz	MODE VIE	Animaux	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	animaux	Un partenaire avec des animaux :	f	\N
chev_longueur_moi	45	quiz	PHYSIQUE	Cheveux	⚪ ESTHÉTIQUE - Style & Attributs	self	chev_longueur	Quelle est ma longueur de cheveux ?	f	\N
chev_longueur_rech	46	quiz	PHYSIQUE	Cheveux	⚪ ESTHÉTIQUE - Style & Attributs	pref	chev_longueur	Quelle longueur de cheveux j'aime ?	f	\N
chev_couleur_moi	47	quiz	PHYSIQUE	Cheveux	⚪ ESTHÉTIQUE - Style & Attributs	self	chev_couleur	Quelle est ma couleur de cheveux ?	f	\N
chev_couleur_rech	48	quiz	PHYSIQUE	Cheveux	⚪ ESTHÉTIQUE - Style & Attributs	pref	chev_couleur	Quelle couleur de cheveux j'aime ?	f	\N
chev_forme_moi	49	backend	PHYSIQUE	Cheveux	⚪ ESTHÉTIQUE - Style & Attributs	self	chev_forme	Quelle est la forme de mes cheveux ?	f	\N
chev_forme_rech	50	backend	PHYSIQUE	Cheveux	⚪ ESTHÉTIQUE - Style & Attributs	pref	chev_forme	Quelle forme de cheveux j'aime ?	f	\N
chev_volume_moi	51	backend	PHYSIQUE	Cheveux	⚪ ESTHÉTIQUE - Style & Attributs	self	chev_volume	Ai-je beaucoup de volume capillaire?	f	\N
chev_volume_rech	52	backend	PHYSIQUE	Cheveux	⚪ ESTHÉTIQUE - Style & Attributs	pref	chev_volume	Aime-je les chevelures volumineuses ?	f	\N
com_integ_moi	157	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_integ	Pour m'intégrer, je suis :	f	\N
com_integ_rech	158	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_integ	J'aime que l'autre soit :	f	\N
com_drague_moi	159	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_drague	Pour draguer, j'utilise :	f	\N
com_drague_rech	160	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_drague	J'aime me faire aborder de façon :	f	\N
com_ecoute_moi	161	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_ecoute	En discussion :	f	\N
com_ecoute_rech	162	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_ecoute	J'ai besoin de quelqu'un qui :	f	\N
com_emot_moi	163	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_emot	Mes émotions :	f	\N
com_humour_moi	165	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_humour	Mon humour :	f	\N
com_humour_rech	166	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_humour	L'humour qui me fait rire :	f	\N
com_canal_moi	167	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_canal	Mon canal de com préféré :	f	\N
com_canal_rech	168	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_canal	J'attends qu'il/elle soit :	f	\N
com_conflit_moi	169	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_conflit	Face aux conflits :	f	\N
com_conflit_rech	170	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_conflit	Lors d'une dispute, l'autre doit :	f	\N
com_franchis_moi	171	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_franchis	Ma franchise :	f	\N
com_franchis_rech	172	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_franchis	L'honnêteté chez l'autre doit être :	f	\N
com_critiq_moi	173	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_critiq	Je suis sensible aux critiques :	f	\N
com_critiq_rech	174	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_critiq	Avoir un partenaire susceptible me dérange :	f	\N
com_empathie_moi	175	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_empathie	Je fais preuve d'empathie :	f	\N
com_empathie_rech	176	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_empathie	L'empathie de l'autre est :	f	\N
com_patienc_moi	177	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	com_patienc	Je suis quelqu'un de patient :	f	\N
com_patienc_rech	178	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_patienc	J'ai besoin de quelqu'un de patient avec moi:	f	\N
db_relation_moi	235	onboarding	COUPLE	Dealbreakers	🔴 FILTRE ABSOLU	self	db_relation	Actuellement, j'envisage une relation :	f	\N
db_relation_rech	236	onboarding	COUPLE	Dealbreakers	🔴 FILTRE ABSOLU	pref	db_relation	Je cherche quelqu'un qui veut :	f	\N
db_mariage_moi	237	onboarding	COUPLE	Dealbreakers	🔴 FILTRE ABSOLU	self	db_mariage	Concernant le mariage :	f	\N
db_mariage_rech	238	onboarding	COUPLE	Dealbreakers	🔴 FILTRE ABSOLU	pref	db_mariage	Mon partenaire doit vouloir se marier un jour :	f	\N
db_enfants_moi	239	onboarding	COUPLE	Dealbreakers	🔴 FILTRE ABSOLU	self	db_enfants	Concernant les enfants :	f	\N
db_enfants_rech	240	onboarding	COUPLE	Dealbreakers	🔴 FILTRE ABSOLU	pref	db_enfants	Je veux rencontrer quelqu'un qui :	f	\N
db_regime_moi	263	onboarding	COUPLE	Dealbreakers	🔴 FILTRE ABSOLU	self	db_regime	Je suis :	f	\N
db_regime_rech	264	onboarding	COUPLE	Dealbreakers	🔴 FILTRE ABSOLU	pref	db_regime	Le régime de l'autre est-il un dealbreaker ?	f	\N
fin_comport_moi	147	quiz	MODE VIE	Finances	🔵 CLUSTER 2 - Stabilité vs Aventure	self	fin_comport	Avec mon argent, je suis :	f	\N
fin_comport_rech	148	quiz	MODE VIE	Finances	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	fin_comport	Je supporterais mal un partenaire :	f	\N
fin_vision_moi	149	quiz	MODE VIE	Finances	🔵 CLUSTER 2 - Stabilité vs Aventure	self	fin_vision	Mon rapport à l'argent :	f	\N
fin_vision_rech	150	quiz	MODE VIE	Finances	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	fin_vision	Je cherche quelqu'un qui vise :	f	\N
life_sommeil_moi	85	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	self	life_sommeil	Quel est mon rythme de sommeil ?	f	\N
life_sommeil_rech	86	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	pref	life_sommeil	Quel rythme j'attends de l'autre ?	f	\N
life_horaires_moi	87	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	self	life_horaires	Mes horaires de vie sont-ils :	f	\N
life_horaires_rech	88	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	pref	life_horaires	J'ai besoin que mon partenaire soit :	f	\N
life_energie_moi	89	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	self	life_energie	Au quotidien, je suis plutôt :	f	\N
life_energie_rech	90	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	pref	life_energie	J'aime que l'autre soit :	f	\N
life_orga_moi	91	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	self	life_orga	En organisation, je suis :	f	\N
com_emot_rech	164	quiz	VALEURS	Com	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	com_emot	Au niveau des émotions, je veux que mon/ma partenaire :	f	\N
life_orga_rech	92	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	pref	life_orga	Je veux vivre avec quelqu'un de :	f	\N
life_ecrans_moi	101	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	self	life_ecrans	Mon usage des écrans :	f	\N
life_ecrans_rech	102	quiz	MODE VIE	Habitudes	🟢 CLUSTER 1 - Rythme & Énergie	pref	life_ecrans	Je supporte mal un partenaire :	f	\N
life_objets_moi	93	quiz	MODE VIE	Habitudes	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	life_objets	Avec mes affaires, je suis :	f	\N
life_objets_rech	94	quiz	MODE VIE	Habitudes	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	life_objets	Chez l'autre, je préfère le côté :	f	\N
life_cuisine_moi	95	quiz	MODE VIE	Habitudes	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	life_cuisine	En cuisine :	f	\N
life_cuisine_rech	96	quiz	MODE VIE	Habitudes	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	life_cuisine	J'attends de l'autre :	f	\N
life_proprete_moi	97	quiz	MODE VIE	Habitudes	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	life_proprete	Niveau propreté, je suis :	f	\N
life_proprete_rech	98	quiz	MODE VIE	Habitudes	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	life_proprete	Je veux que mon partenaire soit :	f	\N
life_manuel_moi	99	quiz	MODE VIE	Habitudes	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	life_manuel	Je suis habile pour :	f	\N
life_manuel_rech	100	quiz	MODE VIE	Habitudes	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	life_manuel	J'adore quand mon partenaire sait :	f	\N
life_job_moi	103	quiz	MODE VIE	Habitudes	🔵 CLUSTER 2 - Stabilité vs Aventure	self	life_job	Mon rythme de job :	f	\N
life_job_rech	104	quiz	MODE VIE	Habitudes	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	life_job	Je préfère que l'autre ait :	f	\N
loisir_num_moi	105	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	self	loisir_num	Mon divertissement numérique :	f	\N
loisir_num_rech	106	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	pref	loisir_num	J'aimerais partager avec lui/elle :	f	\N
loisir_cult_moi	107	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	self	loisir_cult	Pour m'instruire, je préfère :	f	\N
loisir_cult_rech	108	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	pref	loisir_cult	J'aimerais qu'on aille ensemble :	f	\N
loisir_amis_moi	109	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	self	loisir_amis	Ma soirée idéale entre amis :	f	\N
loisir_amis_rech	110	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	pref	loisir_amis	Mon partenaire idéal aime :	f	\N
loisir_arts_moi	111	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	self	loisir_arts	Je suis captivé(e) par :	f	\N
loisir_arts_rech	112	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	pref	loisir_arts	J'aimerais qu'il/elle soit attiré par :	f	\N
loisir_passion_moi	113	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	self	loisir_passion	Je suis passionné(e) par :	f	\N
loisir_passion_rech	114	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	pref	loisir_passion	J'aimerais qu'il/elle aime :	f	\N
loisir_benev_moi	115	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	self	loisir_benev	Je fais du bénévolat :	f	\N
loisir_benev_rech	116	quiz	MODE VIE	Loisirs	⚪ LOISIRS - Passions & Culture	pref	loisir_benev	L'engagement associatif chez l'autre:	f	\N
proj_prio_moi	251	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	self	proj_prio	Ma priorité de vie :	f	\N
proj_prio_rech	252	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	proj_prio	J'aimerais que sa priorité soit :	f	\N
proj_statut_moi	253	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	self	proj_statut	Je travaille (ou veux travailler) en tant que :	f	\N
proj_statut_rech	254	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	proj_statut	J'admire les partenaires qui sont :	f	\N
proj_lieu_moi	255	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	self	proj_lieu	Je veux vivre en :	f	\N
proj_lieu_rech	256	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	proj_lieu	On devra se mettre d'accord pour vivre en :	f	\N
proj_ancrage_moi	257	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	self	proj_ancrage	Mon but géographique :	f	\N
proj_ancrage_rech	258	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	proj_ancrage	J'ai besoin qu'il/elle ait envie de :	f	\N
proj_retraite_moi	259	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	self	proj_retraite	Mon plan à long terme :	f	\N
proj_retraite_rech	260	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	proj_retraite	L'idéal de vie à deux serait :	f	\N
proj_rythme_moi	261	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	self	proj_rythme	Mon rythme global recherché :	f	\N
proj_rythme_rech	262	quiz	PROJETS	Long terme	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	proj_rythme	Mon/ma complice devra être prêt(e) à :	f	\N
mob_transp_moi	151	quiz	MODE VIE	Mobilité	🔵 CLUSTER 2 - Stabilité vs Aventure	self	mob_transp	Pour me déplacer, j'utilise :	f	\N
mob_transp_rech	152	quiz	MODE VIE	Mobilité	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	mob_transp	Mon partenaire doit être :	f	\N
phys_silhouette_moi	7	backend	PHYSIQUE	Morphologie	🟠 CLUSTER 5 - Hygiène de Vie & Physique	self	phys_silhouette	Quelle est ma silhouette globale ?	f	\N
phys_silhouette_rech	8	backend	PHYSIQUE	Morphologie	🟠 CLUSTER 5 - Hygiène de Vie & Physique	pref	phys_silhouette	Quelle silhouette m'attire le plus ?	f	\N
phys_taille_moi	3	onboarding	PHYSIQUE	Morphologie	⚪ ESTHÉTIQUE - Morphologie	self	phys_taille	Quelle est ma taille ?	f	\N
phys_taille_rech	4	onboarding	PHYSIQUE	Morphologie	⚪ ESTHÉTIQUE - Morphologie	pref	phys_taille	Quelle taille j'aime chez mon partenaire ?	f	\N
phys_poids_moi	5	onboarding	PHYSIQUE	Morphologie	⚪ ESTHÉTIQUE - Morphologie	self	phys_poids	Quel est mon poids actuel ?	f	\N
phys_poids_rech	6	onboarding	PHYSIQUE	Morphologie	⚪ ESTHÉTIQUE - Morphologie	pref	phys_poids	Quel poids je préfère chez l'autre ?	f	\N
phys_poitrine_moi	9	backend	PHYSIQUE	Morphologie	⚪ ESTHÉTIQUE - Morphologie	self	phys_poitrine	Quel est le volume de ma poitrine ?	f	\N
phys_poitrine_rech	10	backend	PHYSIQUE	Morphologie	⚪ ESTHÉTIQUE - Morphologie	pref	phys_poitrine	Quel volume de poitrine je préfère ?	f	\N
peau_bronzage_moi	63	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	self	peau_bronzage	Suis-je souvent bronzé(e) ?	f	\N
peau_bronzage_rech	64	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	pref	peau_bronzage	Aime-je les teints bronzés ?	f	\N
peau_rousseur_moi	65	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	self	peau_rousseur	Ai-je des taches de rousseur ?	f	\N
peau_rousseur_rech	66	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	pref	peau_rousseur	Aime-je les taches de rousseur ?	f	\N
peau_grains_beaute_m	67	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	self	peau_grains_beaute	Ai-je des grains de beauté visibles ?	f	\N
peau_grains_beaute_r	68	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	pref	peau_grains_beaute	Est-ce que j'aime ce détail ?	f	\N
peau_cicatrices_moi	69	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	self	peau_cicatrices	Ai-je des cicatrices visibles ?	f	\N
peau_cicatrices_rech	70	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	pref	peau_cicatrices	Est-ce que ça me dérange chez l'autre?	f	\N
peau_acne_moi	71	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	self	peau_acne	Ai-je de l'acné / des imperfections ?	f	\N
peau_acne_rech	72	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	pref	peau_acne	Est-ce un dealbreaker chez l'autre ?	f	\N
peau_rides_moi	73	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	self	peau_rides	Ai-je des rides visibles ?	f	\N
peau_rides_rech	74	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	pref	peau_rides	Les rides me dérangent-elles ?	f	\N
pil_barbe_moi	53	quiz	PHYSIQUE	Pilosité	⚪ ESTHÉTIQUE - Style & Attributs	self	pil_barbe	Comment est ma barbe ?	f	\N
pil_barbe_rech	54	quiz	PHYSIQUE	Pilosité	⚪ ESTHÉTIQUE - Style & Attributs	pref	pil_barbe	Quel style de barbe je préfère ?	f	\N
pil_moustache_moi	55	quiz	PHYSIQUE	Pilosité	⚪ ESTHÉTIQUE - Style & Attributs	self	pil_moustache	Ai-je une moustache ou un bouc ?	f	\N
pil_moustache_rech	56	quiz	PHYSIQUE	Pilosité	⚪ ESTHÉTIQUE - Style & Attributs	pref	pil_moustache	Aime-je la moustache ou le bouc ?	f	\N
pil_corps_moi	57	quiz	PHYSIQUE	Pilosité	⚪ ESTHÉTIQUE - Style & Attributs	self	pil_corps	Comment est ma pilosité corporelle ?	f	\N
pil_corps_rech	58	quiz	PHYSIQUE	Pilosité	⚪ ESTHÉTIQUE - Style & Attributs	pref	pil_corps	Quelle pilosité corporelle m'attire ?	f	\N
pil_sourcils_moi	59	backend	PHYSIQUE	Pilosité	⚪ ESTHÉTIQUE - Style & Attributs	self	pil_sourcils	Comment sont mes sourcils ?	f	\N
pil_sourcils_rech	60	backend	PHYSIQUE	Pilosité	⚪ ESTHÉTIQUE - Style & Attributs	pref	pil_sourcils	Quels sourcils je préfère ?	f	\N
val_but_moi	213	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	val_but	Je vis avant tout pour :	f	\N
val_but_rech	214	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	val_but	Mon/ma partenaire devrait viser :	f	\N
val_fidelite_moi	215	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	val_fidelite	Sur une échelle de 1 à 5, je suis fidèle à :	f	\N
val_honnete_moi	217	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	val_honnete	Sur une échelle de 1 à 5, je suis honnête à :	f	\N
val_honnete_rech	218	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	val_honnete	J'exige de l'honnêteté à :	f	\N
val_ecolo_moi	225	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	val_ecolo	Mon engagement écologiste (1-5) :	f	\N
val_ecolo_rech	226	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	val_ecolo	Je veux que mon partenaire recycle/soit écolo :	f	\N
val_tradition_moi	227	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	val_tradition	Mon attachement aux traditions (1-5) :	f	\N
val_tradition_rech	228	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	val_tradition	Mon partenaire doit respecter les traditions :	f	\N
val_etudes_moi	231	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	val_etudes	Mon niveau d'études est :	f	\N
val_morale_moi	233	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	val_morale	Mes valeurs fortes sont (choix 1) :	f	\N
val_morale_rech	234	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	val_morale	Je recherche avant tout chez l'autre :	f	\N
val_culture_moi	229	quiz	VALEURS	Profil	⚪ LOISIRS - Passions & Culture	self	val_culture	Mon intérêt pour la culture (1-5) :	f	\N
val_culture_rech	230	quiz	VALEURS	Profil	⚪ LOISIRS - Passions & Culture	pref	val_culture	Je cherche quelqu'un de très cultivé :	f	\N
psy_confianc_moi	179	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_confianc	J'ai confiance en moi :	f	\N
psy_confianc_rech	180	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_confianc	Un partenaire sûr de lui m'attire :	f	\N
psy_anxiete_moi	181	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_anxiete	Je suis de nature anxieuse :	f	\N
psy_anxiete_rech	182	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_anxiete	Aider un partenaire anxieux me fait peur :	f	\N
psy_vision_moi	183	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_vision	Ma vision de la vie :	f	\N
psy_vision_rech	184	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_vision	Je veux m'entourer de quelqu'un :	f	\N
psy_curiosit_moi	185	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_curiosit	Je suis curieux(se) :	f	\N
psy_curiosit_rech	186	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_curiosit	La curiosité intellectuelle de l'autre :	f	\N
psy_creativ_moi	187	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_creativ	Je suis créatif(ve) :	f	\N
val_etudes_rech	232	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	val_etudes	Je recherche quelqu'un qui a un niveau de scolarité minimum :	f	\N
val_fidelite_rech	216	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	val_fidelite	Exigence de l'exclusivité / fidélité envers l'autre :	f	\N
psy_creativ_rech	188	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_creativ	Un esprit artistique chez l'autre :	f	\N
psy_rigueur_moi	189	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_rigueur	Je fais preuve de :	f	\N
psy_rigueur_rech	190	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_rigueur	J'aime que l'autre soit :	f	\N
psy_competit_moi	191	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_competit	Je suis compétitif(ve) :	f	\N
psy_competit_rech	192	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_competit	Un partenaire qui veut toujours gagner :	f	\N
psy_action_moi	193	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_action	Avant d'agir :	f	\N
psy_action_rech	194	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_action	Je préfère un caractère :	f	\N
psy_risque_moi	195	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_risque	Face au risque, je suis :	f	\N
psy_risque_rech	196	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_risque	J'ai besoin de quelqu'un qui :	f	\N
psy_ambition_moi	197	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_ambition	J'ai de l'ambition :	f	\N
psy_ambition_rech	198	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_ambition	L'ambition (pro/perso) chez l'autre :	f	\N
psy_humilite_moi	199	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_humilite	Je fais preuve d'humilité :	f	\N
psy_humilite_rech	200	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_humilite	Quelqu'un qui se vante beaucoup :	f	\N
psy_control_moi	201	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_control	J'ai un gros besoin de contrôle :	f	\N
psy_control_rech	202	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_control	J'accepte que l'autre dirige souvent :	f	\N
psy_adaptab_moi	203	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_adaptab	Je m'adapte facilement :	f	\N
psy_adaptab_rech	204	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_adaptab	L'adaptabilité de mon partenaire :	f	\N
psy_spontan_moi	205	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_spontan	Je suis très spontané(e) :	f	\N
psy_spontan_rech	206	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_spontan	J'adore les surprises de dernière minute :	f	\N
psy_discipli_moi	207	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_discipli	Je suis quelqu'un de discipliné :	f	\N
psy_discipli_rech	208	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_discipli	Je cherche un partenaire :	f	\N
psy_persever_moi	209	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_persever	Ma persévérance est forte :	f	\N
psy_persever_rech	210	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_persever	Un trait de caractère qui me plaît :	f	\N
psy_respons_moi	211	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	psy_respons	J'ai un grand sens des responsabilités :	f	\N
psy_respons_rech	212	quiz	VALEURS	Psy	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	psy_respons	Mon partenaire idéal doit être :	f	\N
soc_extra_moi	137	quiz	MODE VIE	Social	🟢 CLUSTER 1 - Rythme & Énergie	self	soc_extra	Côté extraverti, j'ai besoin de :	f	\N
soc_extra_rech	138	quiz	MODE VIE	Social	🟢 CLUSTER 1 - Rythme & Énergie	pref	soc_extra	Chez l'autre, j'aime le côté :	f	\N
soc_intro_moi	139	quiz	MODE VIE	Social	🟢 CLUSTER 1 - Rythme & Énergie	self	soc_intro	Côté introverti, je préfère :	f	\N
soc_intro_rech	140	quiz	MODE VIE	Social	🟢 CLUSTER 1 - Rythme & Énergie	pref	soc_intro	J'apprécie quand l'autre est :	f	\N
soc_reseau_moi	141	quiz	MODE VIE	Social	🟢 CLUSTER 1 - Rythme & Énergie	self	soc_reseau	Mon réseau pro est important :	f	\N
soc_reseau_rech	142	quiz	MODE VIE	Social	🟢 CLUSTER 1 - Rythme & Énergie	pref	soc_reseau	J'admire les gens très "réseau" :	f	\N
soc_amis_moi	145	quiz	MODE VIE	Social	🟢 CLUSTER 1 - Rythme & Énergie	self	soc_amis	Je suis proche de mes amis :	f	\N
soc_amis_rech	146	quiz	MODE VIE	Social	🟢 CLUSTER 1 - Rythme & Énergie	pref	soc_amis	Ses amis doivent être sa priorité :	f	\N
soc_famille_moi	143	quiz	MODE VIE	Social	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	soc_famille	Je suis proche de ma famille :	f	\N
sport_solo_moi	129	quiz	MODE VIE	Sport	🟠 CLUSTER 5 - Hygiène de Vie & Physique	self	sport_solo	En sport solo, je préfère :	f	\N
sport_solo_rech	130	quiz	MODE VIE	Sport	🟠 CLUSTER 5 - Hygiène de Vie & Physique	pref	sport_solo	J'aime quand l'autre pratique :	f	\N
sport_groupe_moi	131	quiz	MODE VIE	Sport	🟠 CLUSTER 5 - Hygiène de Vie & Physique	self	sport_groupe	En sport de groupe, je préfère :	f	\N
sport_groupe_rech	132	quiz	MODE VIE	Sport	🟠 CLUSTER 5 - Hygiène de Vie & Physique	pref	sport_groupe	J'aimerais faire avec lui/elle :	f	\N
sport_eau_moi	133	quiz	MODE VIE	Sport	🟠 CLUSTER 5 - Hygiène de Vie & Physique	self	sport_eau	Mon rapport aux sports d'eau :	f	\N
sport_eau_rech	134	quiz	MODE VIE	Sport	🟠 CLUSTER 5 - Hygiène de Vie & Physique	pref	sport_eau	Mon partenaire doit :	f	\N
sport_freq_moi	135	quiz	MODE VIE	Sport	🟠 CLUSTER 5 - Hygiène de Vie & Physique	self	sport_freq	Mon niveau de sport :	f	\N
sport_freq_rech	136	quiz	MODE VIE	Sport	🟠 CLUSTER 5 - Hygiène de Vie & Physique	pref	sport_freq	Je veux que l'autre soit :	f	\N
style_vetement_moi	75	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	self	style_vetement	Quel est mon style vestimentaire ?	f	\N
style_vetement_rech	76	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	pref	style_vetement	Quel style je préfère chez l'autre ?	f	\N
style_tatouages_moi	77	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	self	style_tatouages	Ai-je des tatouages ?	f	\N
style_tatouages_rech	78	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	pref	style_tatouages	Aime-je les tatouages sur l'autre ?	f	\N
style_piercings_moi	79	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	self	style_piercings	Ai-je des piercings ?	f	\N
style_piercings_rech	80	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	pref	style_piercings	Aime-je les piercings sur l'autre ?	f	\N
soc_famille_rech	144	quiz	MODE VIE	Social	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	soc_famille	Je cherche quelqu'un qui est proche de sa famille :	f	\N
style_maquillage_moi	81	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	self	style_maquillage	Comment je me maquille ?	f	\N
style_maquillage_rec	82	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	pref	style_maquillage	Quel type de maquillage j'aime ?	f	\N
style_parfum_moi	83	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	self	style_parfum	Ai-je un parfum très marqué ?	f	\N
style_parfum_rech	84	quiz	PHYSIQUE	Style	⚪ ESTHÉTIQUE - Style & Attributs	pref	style_parfum	Aime-je quand l'autre est très parfumé?	f	\N
vis_forme_moi	11	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_forme	Quelle est la forme de mon visage ?	f	\N
vis_forme_rech	12	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_forme	Quelle forme de visage m'attire ?	f	\N
vis_symetrie_moi	13	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_symetrie	Mon visage est-il très symétrique ?	f	\N
vis_symetrie_rech	14	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_symetrie	Suis-je attiré par une forte symétrie ?	f	\N
vis_machoire_moi	15	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_machoire	Ai-je la mâchoire marquée ?	f	\N
vis_machoire_rech	16	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_machoire	Aime-je les mâchoires très marquées ?	f	\N
vis_menton_moi	17	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_menton	Ai-je un menton prononcé ?	f	\N
vis_menton_rech	18	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_menton	Aime-je les mentons prononcés ?	f	\N
vis_pommettes_moi	19	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_pommettes	Ai-je des pommettes marquées ?	f	\N
vis_pommettes_rech	20	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_pommettes	Aime-je les pommettes saillantes ?	f	\N
vis_front_moi	21	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_front	Quelle est la largeur de mon front ?	f	\N
vis_front_rech	22	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_front	Quel type de front je préfère ?	f	\N
vis_nez_moi	23	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_nez	Comment est mon nez ?	f	\N
vis_nez_rech	24	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_nez	Quel type de nez j'aime ?	f	\N
vis_levres_moi	25	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_levres	Comment sont mes lèvres ?	f	\N
vis_levres_rech	26	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_levres	Quelles lèvres m'attirent ?	f	\N
vis_sourire_moi	27	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_sourire	Mon sourire est-il visible sur mes photos ?	f	\N
vis_sourire_rech	28	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_sourire	Dois-je voir le sourire de l'autre ?	f	\N
vis_dents_align_moi	29	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_dents_align	Mes dents sont-elles alignées ?	f	\N
vis_dents_align_rech	30	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_dents_align	Est-ce que j'exige des dents alignées ?	f	\N
vis_dents_blanches_m	31	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_dents_blanches	Ai-je les dents très blanches ?	f	\N
vis_dents_blanches_r	32	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_dents_blanches	Est-ce que j'aime les dents ultra blanches?	f	\N
vis_fossettes_moi	33	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_fossettes	Ai-je des fossettes ?	f	\N
vis_fossettes_rech	34	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_fossettes	Est-ce que je craque pour les fossettes ?	f	\N
vis_traits_moi	35	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	self	vis_traits	Comment sont mes traits du visage ?	f	\N
vis_traits_rech	36	backend	PHYSIQUE	Visage	⚪ ESTHÉTIQUE - Visage	pref	vis_traits	Quels traits m'attirent le plus ?	f	\N
cpl_dynamiq_moi	241	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	cpl_dynamiq	Ma dynamique de couple idéale :	f	\N
cpl_dynamiq_rech	242	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	cpl_dynamiq	J'accepterais que mon partenaire voie d'autres gens :	f	\N
cpl_fusion_moi	243	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	cpl_fusion	Dans le couple, je suis :	f	\N
cpl_fusion_rech	244	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	cpl_fusion	Je cherche un(e) partenaire qui :	f	\N
cpl_affect_moi	245	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	cpl_affect	Je suis démonstratif/affectueux :	f	\N
cpl_affect_rech	246	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	cpl_affect	J'aime que l'autre soit câlin(e) / tactile :	f	\N
cpl_espace_moi	247	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	cpl_espace	J'ai besoin d'espace personnel :	f	\N
cpl_espace_rech	248	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	cpl_espace	Si mon partenaire part seul en week-end :	f	\N
cpl_jalous_moi	249	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	self	cpl_jalous	Mon niveau de jalousie :	f	\N
cpl_jalous_rech	250	quiz	COUPLE	Vision	🟣 CLUSTER 4 - Psycho, Com & Conflits	pref	cpl_jalous	Un partenaire un peu jaloux :	f	\N
voyage_aime_moi	117	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	self	voyage_aime	J'aime voyager :	f	\N
voyage_aime_rech	118	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	voyage_aime	Je veux quelqu'un qui :	f	\N
voyage_style_moi	119	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	self	voyage_style	Mes voyages préférés en duo :	f	\N
voyage_style_rech	120	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	voyage_style	J'attends qu'il/elle aime les voyages :	f	\N
voyage_prepa_moi	121	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	self	voyage_prepa	Ma préparation de voyage :	f	\N
voyage_prepa_rech	122	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	voyage_prepa	Je préfère un partenaire :	f	\N
voyage_paysage_moi	123	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	self	voyage_paysage	Les paysages que je cherche :	f	\N
voyage_paysage_rech	124	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	voyage_paysage	J'aimerais qu'on parte vers :	f	\N
voyage_transp_moi	125	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	self	voyage_transp	Pour voyager je prends :	f	\N
vice_conso_moi	155	onboarding	MODE VIE	Vices (DB)	🟠 CLUSTER 5 - Hygiène de Vie & Physique	self	vice_conso	Mes vices de la vie :	t	sante
voyage_transp_rech	126	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	voyage_transp	Mon partenaire doit être prêt à :	f	\N
voyage_expat_moi	127	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	self	voyage_expat	Expatriation envisageable pour moi :	f	\N
voyage_expat_rech	128	quiz	MODE VIE	Voyages	🔵 CLUSTER 2 - Stabilité vs Aventure	pref	voyage_expat	L'autre doit-il être ouvert à l'expat ?	f	\N
yeux_couleur_moi	37	quiz	PHYSIQUE	Yeux	⚪ ESTHÉTIQUE - Visage	self	yeux_couleur	Quelle est la couleur de mes yeux ?	f	\N
yeux_couleur_rech	38	quiz	PHYSIQUE	Yeux	⚪ ESTHÉTIQUE - Visage	pref	yeux_couleur	Quelle couleur d'yeux j'aime ?	f	\N
yeux_forme_moi	39	backend	PHYSIQUE	Yeux	⚪ ESTHÉTIQUE - Style & Attributs	self	yeux_forme	Quelle est la forme de mes yeux ?	f	\N
yeux_forme_rech	40	backend	PHYSIQUE	Yeux	⚪ ESTHÉTIQUE - Style & Attributs	pref	yeux_forme	Quelle forme d'yeux m'attire ?	f	\N
yeux_cils_moi	41	backend	PHYSIQUE	Yeux	⚪ ESTHÉTIQUE - Style & Attributs	self	yeux_cils	Mes cils sont-ils marqués / longs ?	f	\N
yeux_cils_rech	42	backend	PHYSIQUE	Yeux	⚪ ESTHÉTIQUE - Style & Attributs	pref	yeux_cils	Est-ce un détail qui me plaît ?	f	\N
yeux_lunettes_moi	43	quiz	PHYSIQUE	Yeux	⚪ ESTHÉTIQUE - Style & Attributs	self	yeux_lunettes	Est-ce que je porte des lunettes ?	f	\N
yeux_lunettes_rech	44	quiz	PHYSIQUE	Yeux	⚪ ESTHÉTIQUE - Style & Attributs	pref	yeux_lunettes	Est-ce que j'aime les porteurs de lunettes ?	f	\N
peau_couleur_moi	61	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	self	peau_couleur	Quelle est ma couleur de peau ?	f	origine_ethnique
peau_couleur_rech	62	backend	PHYSIQUE	Peau	⚪ ESTHÉTIQUE - Peau	pref	peau_couleur	Quelle couleur de peau m'attire ?	f	origine_ethnique
val_religion_moi	219	onboarding	VALEURS	Profil	🔴 FILTRE ABSOLU	self	val_religion	Mon intérêt pour la religion (1 à 5) :	f	convictions_religieuses
val_spirit_moi	221	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	val_spirit	Mon intérêt pour la spiritualité (1-5):	f	convictions_religieuses
val_spirit_rech	222	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	val_spirit	L'autre doit-il être spirituel ?	f	convictions_religieuses
val_politique_moi	223	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	self	val_politique	Mon engagement politique (1-5) :	f	opinions_politiques
db_sex_or_moi	265	onboarding	COUPLE	Sexe	🔴 FILTRE ABSOLU	self	db_sex_or	Quelle est mon orientation sexuelle ?	f	orientation_sexuelle
db_sex_or_rech	266	onboarding	COUPLE	Sexe	🔴 FILTRE ABSOLU	pref	db_sex_or	Je cherche un(e) partenaire (algo) :	f	orientation_sexuelle
vice_conso_rech	156	onboarding	MODE VIE	Vices (DB)	🟠 CLUSTER 5 - Hygiène de Vie & Physique	pref	vice_conso	Ce que j'accepte chez l'autre :	f	sante
genre_moi	1	onboarding	PHYSIQUE	Genre & Sexe	🔴 FILTRE ABSOLU	self	genre	Quel est mon genre ?	f	identite_genre
genre_rech	2	onboarding	PHYSIQUE	Genre & Sexe	🔴 FILTRE ABSOLU	pref	genre	Quel genre je recherche ?	f	identite_genre
val_politique_rech	224	quiz	VALEURS	Profil	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	pref	val_politique	L'autre doit-il/elle avoir un engagement politique ?	f	opinions_politiques
val_religion_rech	220	onboarding	VALEURS	Profil	🔴 FILTRE ABSOLU	pref	val_religion	Importance de la croyance en religion pour mon/ma partenaire :	f	convictions_religieuses
\.


--
-- Data for Name: criterion_options; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.criterion_options (criterion_key, idx, label, is_neutral, value_min, value_max, unit) FROM stdin;
genre_moi	0	Homme	f	\N	\N	\N
genre_moi	1	Femme	f	\N	\N	\N
genre_moi	2	Non-binaire	f	\N	\N	\N
genre_rech	0	Homme	f	\N	\N	\N
genre_rech	1	Femme	f	\N	\N	\N
genre_rech	2	Non-binaire	f	\N	\N	\N
phys_silhouette_moi	0	Mince	f	\N	\N	\N
phys_silhouette_moi	1	Athlétique/Musclé	f	\N	\N	\N
phys_silhouette_moi	2	Moyenne	f	\N	\N	\N
phys_silhouette_moi	3	Ronde/Forte	f	\N	\N	\N
phys_silhouette_rech	0	Mince	f	\N	\N	\N
phys_silhouette_rech	1	Athlétique/Musclé	f	\N	\N	\N
phys_silhouette_rech	2	Moyenne	f	\N	\N	\N
phys_silhouette_rech	3	Ronde/Forte	f	\N	\N	\N
phys_taille_moi	1	145-154 cm	f	145	154	cm
phys_poitrine_moi	0	Inexistante / Faible	f	\N	\N	\N
phys_poitrine_moi	1	Moyenne	f	\N	\N	\N
phys_poitrine_moi	2	Grande poitrine	f	\N	\N	\N
phys_poitrine_moi	3	Non applicable	f	\N	\N	\N
phys_poitrine_rech	0	Inexistante / Faible	f	\N	\N	\N
phys_poitrine_rech	1	Moyenne	f	\N	\N	\N
phys_poitrine_rech	2	Grande poitrine	f	\N	\N	\N
phys_poitrine_rech	3	Non applicable	f	\N	\N	\N
phys_taille_moi	2	155-160 cm	f	155	160	cm
vis_forme_moi	0	Ovale	f	\N	\N	\N
vis_forme_moi	1	Rond	f	\N	\N	\N
vis_forme_moi	2	Anguleux	f	\N	\N	\N
vis_forme_rech	0	Ovale	f	\N	\N	\N
vis_forme_rech	1	Rond	f	\N	\N	\N
vis_forme_rech	2	Anguleux	f	\N	\N	\N
phys_taille_moi	3	161-165 cm	f	161	165	cm
vis_symetrie_moi	0	Oui	f	\N	\N	\N
vis_symetrie_moi	1	Non	f	\N	\N	\N
vis_symetrie_rech	0	Oui	f	\N	\N	\N
phys_taille_moi	4	166-170 cm	f	166	170	cm
vis_machoire_moi	0	Oui	f	\N	\N	\N
vis_machoire_moi	1	Non	f	\N	\N	\N
vis_machoire_rech	0	Oui	f	\N	\N	\N
vis_machoire_rech	1	Non	f	\N	\N	\N
phys_taille_moi	5	171-175 cm	f	171	175	cm
vis_menton_moi	0	Oui	f	\N	\N	\N
vis_menton_moi	1	Non	f	\N	\N	\N
vis_menton_rech	0	Oui	f	\N	\N	\N
vis_menton_rech	1	Non	f	\N	\N	\N
phys_taille_moi	6	176-180 cm	f	176	180	cm
vis_pommettes_moi	0	Oui	f	\N	\N	\N
vis_pommettes_moi	1	Non	f	\N	\N	\N
vis_pommettes_rech	0	Oui	f	\N	\N	\N
vis_pommettes_rech	1	Non	f	\N	\N	\N
phys_taille_moi	7	181-185 cm	f	181	185	cm
vis_front_moi	0	Large	f	\N	\N	\N
vis_front_moi	1	Étroit	f	\N	\N	\N
vis_front_moi	2	Normal	f	\N	\N	\N
vis_front_rech	0	Large	f	\N	\N	\N
vis_front_rech	1	Étroit	f	\N	\N	\N
vis_front_rech	2	Normal	f	\N	\N	\N
phys_taille_moi	8	186-190 cm	f	186	190	cm
vis_nez_moi	0	Fin	f	\N	\N	\N
vis_nez_moi	1	Large	f	\N	\N	\N
vis_nez_moi	2	Normal	f	\N	\N	\N
vis_nez_rech	0	Fin	f	\N	\N	\N
vis_nez_rech	1	Large	f	\N	\N	\N
vis_nez_rech	2	Normal	f	\N	\N	\N
vis_levres_moi	0	Fines	f	\N	\N	\N
vis_levres_moi	1	Pulpeuses	f	\N	\N	\N
vis_levres_moi	2	Moyennes	f	\N	\N	\N
vis_levres_rech	0	Fines	f	\N	\N	\N
vis_levres_rech	1	Pulpeuses	f	\N	\N	\N
vis_levres_rech	2	Moyennes	f	\N	\N	\N
vis_sourire_moi	0	Oui	f	\N	\N	\N
vis_sourire_moi	1	Non	f	\N	\N	\N
vis_sourire_rech	0	Oui (Essentiel)	f	\N	\N	\N
vis_sourire_rech	1	Non	f	\N	\N	\N
phys_taille_rech	1	145-154 cm	f	145	154	cm
vis_dents_align_moi	0	Oui	f	\N	\N	\N
vis_dents_align_moi	1	Non	f	\N	\N	\N
vis_dents_align_rech	0	Oui	f	\N	\N	\N
vis_dents_align_rech	1	Non	f	\N	\N	\N
phys_taille_rech	2	155-160 cm	f	155	160	cm
vis_dents_blanches_m	0	Oui	f	\N	\N	\N
vis_dents_blanches_m	1	Non	f	\N	\N	\N
vis_dents_blanches_r	0	Oui	f	\N	\N	\N
vis_dents_blanches_r	1	Non	f	\N	\N	\N
vis_fossettes_moi	0	Oui	f	\N	\N	\N
vis_fossettes_moi	1	Non	f	\N	\N	\N
vis_fossettes_rech	0	Oui	f	\N	\N	\N
vis_fossettes_rech	1	Non	f	\N	\N	\N
vis_traits_moi	0	Fins	f	\N	\N	\N
vis_traits_moi	1	Marqués / Durs	f	\N	\N	\N
vis_traits_rech	0	Fins	f	\N	\N	\N
vis_traits_rech	1	Marqués / Durs	f	\N	\N	\N
phys_taille_rech	3	161-165 cm	f	161	165	cm
yeux_couleur_moi	0	Bleus	f	\N	\N	\N
yeux_couleur_moi	1	Verts	f	\N	\N	\N
yeux_couleur_moi	2	Marrons	f	\N	\N	\N
yeux_couleur_moi	3	Noirs	f	\N	\N	\N
yeux_couleur_moi	4	Gris	f	\N	\N	\N
yeux_couleur_moi	5	Vairons	f	\N	\N	\N
yeux_couleur_rech	0	Bleus	f	\N	\N	\N
yeux_couleur_rech	1	Verts	f	\N	\N	\N
yeux_couleur_rech	2	Marrons	f	\N	\N	\N
yeux_couleur_rech	3	Noirs	f	\N	\N	\N
yeux_couleur_rech	4	Gris	f	\N	\N	\N
yeux_couleur_rech	5	Vairons	f	\N	\N	\N
phys_taille_rech	4	166-170 cm	f	166	170	cm
yeux_forme_moi	0	En amande	f	\N	\N	\N
yeux_forme_moi	1	Ronds	f	\N	\N	\N
yeux_forme_moi	2	Bridés	f	\N	\N	\N
yeux_forme_rech	0	En amande	f	\N	\N	\N
yeux_forme_rech	1	Ronds	f	\N	\N	\N
yeux_forme_rech	2	Bridés	f	\N	\N	\N
phys_taille_rech	5	171-175 cm	f	171	175	cm
yeux_cils_moi	0	Oui	f	\N	\N	\N
yeux_cils_moi	1	Non	f	\N	\N	\N
yeux_cils_rech	0	Oui	f	\N	\N	\N
yeux_cils_rech	1	Non	f	\N	\N	\N
phys_taille_rech	6	176-180 cm	f	176	180	cm
yeux_lunettes_moi	0	Oui	f	\N	\N	\N
yeux_lunettes_moi	1	Non	f	\N	\N	\N
yeux_lunettes_rech	0	Oui	f	\N	\N	\N
yeux_lunettes_rech	1	Non	f	\N	\N	\N
phys_taille_rech	7	181-185 cm	f	181	185	cm
chev_longueur_moi	0	Très courts/Rasé	f	\N	\N	\N
chev_longueur_moi	1	Courts	f	\N	\N	\N
chev_longueur_moi	2	Mi-longs	f	\N	\N	\N
chev_longueur_moi	3	Longs	f	\N	\N	\N
chev_longueur_moi	4	Chauve	f	\N	\N	\N
chev_longueur_rech	0	Très courts/Rasé	f	\N	\N	\N
chev_longueur_rech	1	Courts	f	\N	\N	\N
chev_longueur_rech	2	Mi-longs	f	\N	\N	\N
chev_longueur_rech	3	Longs	f	\N	\N	\N
chev_longueur_rech	4	Chauve	f	\N	\N	\N
phys_taille_rech	8	186-190 cm	f	186	190	cm
chev_couleur_moi	0	Bruns	f	\N	\N	\N
chev_couleur_moi	1	Blonds	f	\N	\N	\N
chev_couleur_moi	2	Roux	f	\N	\N	\N
chev_couleur_moi	3	Noirs	f	\N	\N	\N
chev_couleur_moi	4	Gris / Blancs	f	\N	\N	\N
chev_couleur_moi	5	Artificielle	f	\N	\N	\N
chev_couleur_rech	0	Bruns	f	\N	\N	\N
chev_couleur_rech	1	Blonds	f	\N	\N	\N
chev_couleur_rech	2	Roux	f	\N	\N	\N
chev_couleur_rech	3	Noirs	f	\N	\N	\N
chev_couleur_rech	4	Gris / Blancs	f	\N	\N	\N
chev_couleur_rech	5	Artificielle	f	\N	\N	\N
chev_forme_moi	0	Bouclés	f	\N	\N	\N
chev_forme_moi	1	Ondulés	f	\N	\N	\N
chev_forme_moi	2	Raides	f	\N	\N	\N
chev_forme_moi	3	Frisés / Crépus	f	\N	\N	\N
chev_forme_rech	0	Bouclés	f	\N	\N	\N
chev_forme_rech	1	Ondulés	f	\N	\N	\N
chev_forme_rech	2	Raides	f	\N	\N	\N
chev_forme_rech	3	Frisés / Crépus	f	\N	\N	\N
phys_poids_moi	1	45-51 kg	f	45	51	kg
chev_volume_moi	0	Oui	f	\N	\N	\N
chev_volume_moi	1	Non	f	\N	\N	\N
chev_volume_rech	0	Oui	f	\N	\N	\N
chev_volume_rech	1	Non	f	\N	\N	\N
phys_poids_moi	2	52-58 kg	f	52	58	kg
pil_barbe_moi	0	Longue	f	\N	\N	\N
pil_barbe_moi	1	Courte/Rasé de près	f	\N	\N	\N
pil_barbe_moi	2	Barbe 3 jours	f	\N	\N	\N
pil_barbe_moi	3	Aucune pilosité	f	\N	\N	\N
pil_barbe_rech	0	Longue	f	\N	\N	\N
pil_barbe_rech	1	Courte/Rasé de près	f	\N	\N	\N
pil_barbe_rech	2	Barbe 3 jours	f	\N	\N	\N
pil_barbe_rech	3	Aucune pilosité	f	\N	\N	\N
phys_poids_moi	3	59-65 kg	f	59	65	kg
pil_moustache_moi	0	Moustache	f	\N	\N	\N
pil_moustache_moi	1	Bouc	f	\N	\N	\N
pil_moustache_moi	2	Non	f	\N	\N	\N
pil_moustache_rech	0	Oui (Moustache)	f	\N	\N	\N
pil_moustache_rech	1	Oui (Bouc)	f	\N	\N	\N
pil_moustache_rech	2	Non	f	\N	\N	\N
phys_poids_moi	4	66-72 kg	f	66	72	kg
pil_corps_moi	0	Aucune / Épilé	f	\N	\N	\N
pil_corps_moi	1	Faible	f	\N	\N	\N
pil_corps_moi	2	Forte	f	\N	\N	\N
pil_corps_rech	0	Aucune / Épilé	f	\N	\N	\N
pil_corps_rech	1	Faible	f	\N	\N	\N
pil_corps_rech	2	Forte	f	\N	\N	\N
phys_poids_moi	5	73-79 kg	f	73	79	kg
pil_sourcils_moi	0	Épais	f	\N	\N	\N
pil_sourcils_moi	1	Fins	f	\N	\N	\N
pil_sourcils_moi	2	Tatoués	f	\N	\N	\N
pil_sourcils_rech	0	Épais	f	\N	\N	\N
pil_sourcils_rech	1	Fins	f	\N	\N	\N
pil_sourcils_rech	2	Tatoués	f	\N	\N	\N
phys_poids_moi	6	80-86 kg	f	80	86	kg
peau_couleur_moi	0	Claire	f	\N	\N	\N
peau_couleur_moi	1	Foncée	f	\N	\N	\N
peau_couleur_moi	2	Très foncée	f	\N	\N	\N
peau_couleur_rech	0	Claire	f	\N	\N	\N
peau_couleur_rech	1	Foncée	f	\N	\N	\N
peau_couleur_rech	2	Très foncée	f	\N	\N	\N
phys_poids_moi	7	87-93 kg	f	87	93	kg
peau_bronzage_moi	0	Oui	f	\N	\N	\N
peau_bronzage_moi	1	Non	f	\N	\N	\N
peau_bronzage_rech	0	Oui	f	\N	\N	\N
peau_bronzage_rech	1	Non	f	\N	\N	\N
phys_poids_moi	8	94-104 kg	f	94	104	kg
peau_rousseur_moi	0	Oui	f	\N	\N	\N
peau_rousseur_moi	1	Non	f	\N	\N	\N
peau_rousseur_rech	0	Oui	f	\N	\N	\N
peau_rousseur_rech	1	Non	f	\N	\N	\N
peau_grains_beaute_m	0	Oui	f	\N	\N	\N
peau_grains_beaute_m	1	Non	f	\N	\N	\N
peau_grains_beaute_r	0	Oui	f	\N	\N	\N
peau_grains_beaute_r	1	Non	f	\N	\N	\N
peau_cicatrices_moi	0	Oui	f	\N	\N	\N
peau_cicatrices_moi	1	Non	f	\N	\N	\N
peau_cicatrices_rech	0	Oui, ça me dérange	f	\N	\N	\N
peau_cicatrices_rech	1	Non, ça a du charme	f	\N	\N	\N
peau_acne_rech	1	Non, on a tous des imperfections de peau	f	\N	\N	\N
peau_acne_moi	0	Oui	f	\N	\N	\N
peau_acne_moi	1	Non	f	\N	\N	\N
peau_acne_rech	0	Oui (Doit être lisse)	f	\N	\N	\N
peau_rides_moi	0	Oui	f	\N	\N	\N
peau_rides_moi	1	Non	f	\N	\N	\N
peau_rides_rech	0	Oui	f	\N	\N	\N
peau_rides_rech	1	Non (C'est naturel)	f	\N	\N	\N
phys_poids_rech	1	45-51 kg	f	45	51	kg
style_vetement_moi	0	Élégant / Business	f	\N	\N	\N
style_vetement_moi	1	Casual	f	\N	\N	\N
style_vetement_moi	2	Streetwear / Sportif	f	\N	\N	\N
style_vetement_moi	3	Bohème	f	\N	\N	\N
style_vetement_moi	4	Rock / Alternatif	f	\N	\N	\N
style_vetement_moi	5	Luxe	f	\N	\N	\N
style_vetement_rech	0	Élégant / Business	f	\N	\N	\N
style_vetement_rech	1	Casual	f	\N	\N	\N
style_vetement_rech	2	Streetwear / Sportif	f	\N	\N	\N
style_vetement_rech	3	Bohème	f	\N	\N	\N
style_vetement_rech	4	Rock / Alternatif	f	\N	\N	\N
style_vetement_rech	5	Luxe	f	\N	\N	\N
phys_poids_rech	2	52-58 kg	f	52	58	kg
style_tatouages_moi	0	Oui	f	\N	\N	\N
style_tatouages_moi	1	Non	f	\N	\N	\N
style_tatouages_rech	0	Oui (J'adore)	f	\N	\N	\N
style_tatouages_rech	1	Non (Je n'aime pas)	f	\N	\N	\N
phys_poids_rech	3	59-65 kg	f	59	65	kg
style_piercings_moi	0	Oui	f	\N	\N	\N
style_piercings_moi	1	Non	f	\N	\N	\N
style_piercings_rech	0	Oui	f	\N	\N	\N
style_piercings_rech	1	Non	f	\N	\N	\N
phys_poids_rech	4	66-72 kg	f	66	72	kg
style_maquillage_moi	0	Naturel / Rarement	f	\N	\N	\N
style_maquillage_moi	1	Léger	f	\N	\N	\N
style_maquillage_moi	2	Prononcé	f	\N	\N	\N
style_maquillage_moi	3	Non applicable	f	\N	\N	\N
style_maquillage_rec	0	Naturel / Rarement	f	\N	\N	\N
style_maquillage_rec	1	Léger	f	\N	\N	\N
style_maquillage_rec	2	Prononcé	f	\N	\N	\N
style_maquillage_rec	3	Non applicable	f	\N	\N	\N
phys_poids_rech	5	73-79 kg	f	73	79	kg
style_parfum_moi	0	Oui	f	\N	\N	\N
style_parfum_moi	1	Non	f	\N	\N	\N
style_parfum_rech	0	Oui	f	\N	\N	\N
style_parfum_rech	1	Non	f	\N	\N	\N
phys_poids_rech	6	80-86 kg	f	80	86	kg
life_sommeil_moi	0	Couche-tôt/Lève-tôt	f	\N	\N	\N
life_sommeil_moi	1	Couche-tard/Lève-tard	f	\N	\N	\N
life_sommeil_rech	0	Couche-tôt/Lève-tôt	f	\N	\N	\N
life_sommeil_rech	1	Couche-tard/Lève-tard	f	\N	\N	\N
phys_poids_rech	7	87-93 kg	f	87	93	kg
life_horaires_moi	0	Réguliers	f	\N	\N	\N
life_horaires_moi	1	Flexibles	f	\N	\N	\N
life_horaires_rech	0	Réglé (Régulier)	f	\N	\N	\N
life_horaires_rech	1	Spontané (Flexible)	f	\N	\N	\N
phys_poids_rech	8	94-104 kg	f	94	104	kg
life_energie_moi	0	Casanier	f	\N	\N	\N
life_energie_moi	1	Très actif	f	\N	\N	\N
life_energie_rech	0	Casanier	f	\N	\N	\N
life_energie_rech	1	Très actif	f	\N	\N	\N
life_orga_moi	0	Organisé	f	\N	\N	\N
life_orga_moi	1	Désordonné	f	\N	\N	\N
life_orga_rech	0	Très organisé	f	\N	\N	\N
life_orga_rech	1	Désordonné / Souple	f	\N	\N	\N
phys_taille_moi	0	<145 cm	f	\N	145	cm
life_objets_moi	0	Minimaliste	f	\N	\N	\N
life_objets_moi	1	Collectionneur	f	\N	\N	\N
life_objets_rech	0	Minimaliste	f	\N	\N	\N
life_objets_rech	1	Collectionneur	f	\N	\N	\N
phys_taille_rech	0	<145 cm	f	\N	145	cm
life_cuisine_moi	0	Je connais les bases	f	\N	\N	\N
life_cuisine_moi	1	Je cuisine souvent	f	\N	\N	\N
life_cuisine_moi	2	Je commande souvent	f	\N	\N	\N
life_cuisine_rech	0	Qu'il cuisine bien	f	\N	\N	\N
life_cuisine_rech	1	Qu'il aide (bases)	f	\N	\N	\N
life_cuisine_rech	2	On commandera à 2	f	\N	\N	\N
phys_poids_moi	0	< 45 kg	f	\N	45	kg
life_proprete_moi	0	Pas ma priorité	f	\N	\N	\N
life_proprete_moi	1	Ménage occasionnel	f	\N	\N	\N
life_proprete_moi	2	Je délègue	f	\N	\N	\N
life_proprete_moi	3	Je suis maniaque	f	\N	\N	\N
life_proprete_rech	0	Détendu sur le ménage	f	\N	\N	\N
life_proprete_rech	1	Rigoureux	f	\N	\N	\N
life_proprete_rech	2	Maniaque	f	\N	\N	\N
phys_poids_rech	0	< 45 kg	f	\N	45	kg
life_manuel_moi	0	Bricoler	f	\N	\N	\N
life_manuel_moi	1	Jardiner	f	\N	\N	\N
life_manuel_moi	2	Masser	f	\N	\N	\N
life_manuel_moi	3	Je déteste ça	f	\N	\N	\N
life_manuel_rech	0	Bricoler	f	\N	\N	\N
life_manuel_rech	1	Jardiner	f	\N	\N	\N
life_manuel_rech	2	Masser	f	\N	\N	\N
phys_taille_moi	9	191 cm+	f	191	\N	cm
life_ecrans_moi	0	Intensif (Téléphone)	f	\N	\N	\N
life_ecrans_moi	1	Déconnecté	f	\N	\N	\N
life_ecrans_moi	2	Comportement normal	f	\N	\N	\N
life_ecrans_rech	0	Toujours sur son tel	f	\N	\N	\N
life_ecrans_rech	1	Trop déconnecté	f	\N	\N	\N
life_ecrans_rech	2	Aucun problème	f	\N	\N	\N
life_job_moi	0	Bureau tous les jours	f	\N	\N	\N
life_job_moi	1	Télétravail	f	\N	\N	\N
life_job_moi	2	Déplacements fréquents	f	\N	\N	\N
life_job_moi	3	Stable géographiquement	f	\N	\N	\N
life_job_rech	0	Des horaires fixes	f	\N	\N	\N
life_job_rech	1	Du temps en télétravail	f	\N	\N	\N
life_job_rech	2	Un rythme libre	f	\N	\N	\N
phys_taille_rech	9	191 cm+	f	191	\N	cm
loisir_num_moi	0	Cinéma	f	\N	\N	\N
loisir_num_moi	1	Séries	f	\N	\N	\N
loisir_num_moi	2	Podcasts	f	\N	\N	\N
loisir_num_moi	3	Jeux vidéo	f	\N	\N	\N
loisir_num_rech	0	Le Cinéma	f	\N	\N	\N
loisir_num_rech	1	Les Séries	f	\N	\N	\N
loisir_num_rech	2	Les Podcasts	f	\N	\N	\N
loisir_num_rech	3	Les Jeux vidéo	f	\N	\N	\N
loisir_cult_moi	0	Lecture	f	\N	\N	\N
loisir_cult_moi	1	Théâtre	f	\N	\N	\N
loisir_cult_moi	2	Musées	f	\N	\N	\N
loisir_cult_rech	0	Lire au calme	f	\N	\N	\N
loisir_cult_rech	1	Au Théâtre	f	\N	\N	\N
loisir_cult_rech	2	Aux Musées	f	\N	\N	\N
loisir_amis_moi	0	Jeux de société	f	\N	\N	\N
loisir_amis_moi	1	DIY	f	\N	\N	\N
loisir_amis_moi	2	Concerts / Festivals	f	\N	\N	\N
loisir_amis_moi	3	Boîte de nuit	f	\N	\N	\N
loisir_amis_moi	4	Boire un verre	f	\N	\N	\N
loisir_amis_rech	1	Faire la fête (Boîte)	f	\N	\N	\N
loisir_amis_rech	2	Les concerts	f	\N	\N	\N
loisir_amis_rech	3	Les bars	f	\N	\N	\N
phys_poids_moi	9	105 kg +	f	105	\N	kg
loisir_arts_moi	0	Danse	f	\N	\N	\N
loisir_arts_moi	1	Photographie	f	\N	\N	\N
loisir_arts_moi	2	Dessin	f	\N	\N	\N
loisir_arts_moi	3	Écriture	f	\N	\N	\N
loisir_arts_rech	0	La Danse	f	\N	\N	\N
loisir_arts_rech	1	La Photographie	f	\N	\N	\N
loisir_arts_rech	2	Le Dessin	f	\N	\N	\N
loisir_arts_rech	3	L'Écriture	f	\N	\N	\N
phys_poids_rech	9	105 kg +	f	105	\N	kg
loisir_passion_moi	1	Shopping	f	\N	\N	\N
loisir_passion_moi	2	Mode	f	\N	\N	\N
loisir_passion_moi	3	Collection d'objets	f	\N	\N	\N
loisir_passion_rech	0	Cuisiner	f	\N	\N	\N
loisir_passion_rech	1	Faire du shopping	f	\N	\N	\N
loisir_passion_rech	2	La Mode	f	\N	\N	\N
loisir_passion_rech	3	Collectionner	f	\N	\N	\N
loisir_amis_rech	0	Les activités chill à la maison	f	\N	\N	\N
loisir_benev_moi	0	Oui	f	\N	\N	\N
loisir_benev_moi	1	Non	f	\N	\N	\N
loisir_benev_moi	2	Seulement si défrayé	f	\N	\N	\N
loisir_benev_rech	0	C'est un gros plus	f	\N	\N	\N
sport_eau_rech	0	Aimer les activités aquatiques	f	\N	\N	\N
voyage_aime_moi	0	Oui	f	\N	\N	\N
voyage_aime_rech	0	Aime voyager	f	\N	\N	\N
sport_eau_rech	1	Je n'attends pas de faire des sports aquatiques avec mon/ma partenaire	f	\N	\N	\N
voyage_style_moi	0	Luxe	f	\N	\N	\N
voyage_style_moi	1	Backpacking	f	\N	\N	\N
voyage_style_moi	2	Culturels	f	\N	\N	\N
voyage_style_moi	3	Nature	f	\N	\N	\N
voyage_style_moi	4	Sportifs	f	\N	\N	\N
voyage_style_rech	0	De Luxe	f	\N	\N	\N
voyage_style_rech	1	Backpacking	f	\N	\N	\N
voyage_style_rech	2	Culturels	f	\N	\N	\N
voyage_style_rech	3	Nature	f	\N	\N	\N
voyage_style_rech	4	Sportifs	f	\N	\N	\N
voyage_transp_rech	1	Voyager écolo	f	\N	\N	\N
voyage_prepa_moi	0	Improvisée	f	\N	\N	\N
voyage_prepa_moi	1	Planifiée	f	\N	\N	\N
voyage_prepa_moi	2	J'ai 3 valises	f	\N	\N	\N
loisir_passion_moi	0	Cuisiner	f	\N	\N	\N
voyage_prepa_rech	0	Très organisé (Planifie)	f	\N	\N	\N
voyage_prepa_rech	1	Spontané (Improvise)	f	\N	\N	\N
sport_eau_moi	2	Autres sports aquatiques	f	\N	\N	\N
voyage_paysage_moi	0	La ville	f	\N	\N	\N
voyage_paysage_moi	1	La plage	f	\N	\N	\N
voyage_paysage_moi	2	La montagne	f	\N	\N	\N
voyage_paysage_moi	3	La campagne	f	\N	\N	\N
voyage_paysage_rech	0	La ville	f	\N	\N	\N
voyage_paysage_rech	1	La plage	f	\N	\N	\N
voyage_paysage_rech	2	La montagne	f	\N	\N	\N
voyage_paysage_rech	3	La campagne	f	\N	\N	\N
voyage_aime_moi	1	Je préfère rester à la maison ou dans des lieux que je maîtrise	f	\N	\N	\N
voyage_transp_moi	0	Le train	f	\N	\N	\N
voyage_transp_moi	1	L'avion	f	\N	\N	\N
voyage_transp_moi	2	La voiture	f	\N	\N	\N
voyage_transp_moi	3	Le vélo	f	\N	\N	\N
voyage_transp_moi	4	Le bateau	f	\N	\N	\N
voyage_transp_moi	5	Jamais l'avion	f	\N	\N	\N
voyage_transp_rech	0	Prendre l'avion	f	\N	\N	\N
voyage_transp_rech	2	Faire des roadtrips	f	\N	\N	\N
voyage_aime_rech	1	Préfère être casanier ou dans des lieux qu'il/elle maîtrise	f	\N	\N	\N
voyage_expat_moi	0	Oui	f	\N	\N	\N
voyage_expat_moi	1	Non	f	\N	\N	\N
voyage_expat_rech	0	Oui, absolument	f	\N	\N	\N
voyage_expat_rech	1	Non, on reste ici	f	\N	\N	\N
sport_solo_moi	0	Musculation/Fitness	f	\N	\N	\N
sport_solo_moi	1	Running	f	\N	\N	\N
sport_solo_moi	2	Vélo	f	\N	\N	\N
sport_solo_moi	3	Danse	f	\N	\N	\N
sport_solo_moi	4	Ski	f	\N	\N	\N
sport_solo_rech	0	La Musculation	f	\N	\N	\N
sport_solo_rech	1	Le Running	f	\N	\N	\N
sport_solo_rech	2	Le Vélo	f	\N	\N	\N
sport_solo_rech	3	La Danse	f	\N	\N	\N
sport_solo_rech	4	Le Ski	f	\N	\N	\N
sport_groupe_moi	0	Yoga	f	\N	\N	\N
sport_groupe_moi	1	Pilates	f	\N	\N	\N
sport_groupe_moi	2	Randonnée	f	\N	\N	\N
sport_groupe_moi	3	Escalade	f	\N	\N	\N
sport_groupe_moi	4	Sports de combat	f	\N	\N	\N
sport_groupe_rech	0	Du Yoga/Pilates	f	\N	\N	\N
sport_groupe_rech	1	De la Randonnée	f	\N	\N	\N
sport_groupe_rech	2	De l'Escalade	f	\N	\N	\N
sport_groupe_rech	3	Du combat	f	\N	\N	\N
sport_eau_moi	0	Natation	f	\N	\N	\N
sport_eau_moi	1	Surf	f	\N	\N	\N
sport_eau_moi	3	Déteste l'eau / Sait pas nager	f	\N	\N	\N
sport_freq_moi	0	Peu/Pas sportif	f	\N	\N	\N
sport_freq_moi	1	1 à 2x par semaine	f	\N	\N	\N
sport_freq_moi	2	Toutes les semaines	f	\N	\N	\N
sport_freq_moi	3	Presque tous les jours	f	\N	\N	\N
sport_freq_rech	0	Pas sportif (Tranquille)	f	\N	\N	\N
sport_freq_rech	1	Un peu sportif	f	\N	\N	\N
sport_freq_rech	2	Très sportif	f	\N	\N	\N
sport_freq_rech	3	Athlète acharné	f	\N	\N	\N
soc_extra_moi	0	Grand cercle social	f	\N	\N	\N
soc_extra_moi	1	Recevoir du monde	f	\N	\N	\N
soc_extra_moi	2	Rencontrer des gens	f	\N	\N	\N
soc_extra_moi	3	Vie nocturne active	f	\N	\N	\N
soc_extra_moi	4	Sorties fréquentes	f	\N	\N	\N
soc_extra_rech	0	Très sociable (Sorties)	f	\N	\N	\N
soc_extra_rech	1	Hôte (Aime recevoir)	f	\N	\N	\N
soc_extra_rech	2	Fêtard	f	\N	\N	\N
soc_intro_moi	0	Petit cercle social	f	\N	\N	\N
soc_intro_moi	1	Petits groupes	f	\N	\N	\N
soc_intro_moi	2	Besoin de solitude	f	\N	\N	\N
soc_intro_moi	3	Vie au calme	f	\N	\N	\N
soc_intro_rech	0	Solitaire/Calme	f	\N	\N	\N
soc_intro_rech	1	Intime (Petits comités)	f	\N	\N	\N
soc_intro_rech	2	Indépendant	f	\N	\N	\N
animaux_moi	5	Je déteste les animaux	f	\N	\N	\N
soc_reseau_moi	0	Oui	f	\N	\N	\N
soc_reseau_moi	1	Non	f	\N	\N	\N
soc_reseau_rech	0	Oui	f	\N	\N	\N
soc_reseau_rech	1	Non	f	\N	\N	\N
animaux_moi	6	Je n'aime quasiment que les chiens/chats	f	\N	\N	\N
soc_famille_moi	0	Oui	f	\N	\N	\N
soc_famille_moi	1	Non	f	\N	\N	\N
soc_famille_rech	0	Oui (Esprit famille)	f	\N	\N	\N
soc_famille_rech	1	Non (Indépendant)	f	\N	\N	\N
db_relation_moi	3	Amitié	f	\N	\N	\N
soc_amis_moi	0	Oui	f	\N	\N	\N
soc_amis_moi	1	Non	f	\N	\N	\N
soc_amis_rech	0	Oui, j'aime l'esprit bande	f	\N	\N	\N
soc_amis_rech	1	Non, le couple d'abord	f	\N	\N	\N
db_relation_rech	3	Ouvert(e) à tout type de rencontre	f	\N	\N	\N
fin_comport_moi	0	Dépensier	f	\N	\N	\N
fin_comport_moi	1	Économe	f	\N	\N	\N
fin_comport_moi	2	Investisseur	f	\N	\N	\N
fin_comport_moi	3	Goût du luxe	f	\N	\N	\N
fin_comport_rech	0	Trop radin	f	\N	\N	\N
fin_comport_rech	1	Trop flambeur	f	\N	\N	\N
fin_comport_rech	2	Sans ambition (Investissement)	f	\N	\N	\N
db_relation_rech	4	Amitié	f	\N	\N	\N
fin_vision_moi	0	Recherche stabilité	f	\N	\N	\N
fin_vision_moi	1	Prise de risque	f	\N	\N	\N
fin_vision_moi	2	Consommation responsable	f	\N	\N	\N
fin_vision_rech	0	La sécurité financière	f	\N	\N	\N
fin_vision_rech	1	Le risque (Business)	f	\N	\N	\N
fin_vision_rech	2	L'éthique (Responsable)	f	\N	\N	\N
mob_transp_moi	4	Moto / vélomoteur	f	\N	\N	\N
mob_transp_moi	0	Transports publics	f	\N	\N	\N
mob_transp_moi	1	La voiture	f	\N	\N	\N
mob_transp_moi	2	Le vélo	f	\N	\N	\N
mob_transp_rech	1	Écolo (Vélo/Bus)	f	\N	\N	\N
psy_vision_moi	2	Réaliste	f	\N	\N	\N
animaux_moi	0	Suis gaga (des autres)	f	\N	\N	\N
animaux_moi	1	J'en ai / J'en veux	f	\N	\N	\N
animaux_moi	2	Suis allergique	f	\N	\N	\N
animaux_moi	3	Ai peur d'eux	f	\N	\N	\N
animaux_moi	4	J'aime les atypiques	f	\N	\N	\N
animaux_rech	0	C'est génial	f	\N	\N	\N
animaux_rech	1	C'est non	f	\N	\N	\N
animaux_rech	2	Seulement des chats/chiens	f	\N	\N	\N
psy_vision_rech	2	Peu m'importe	f	\N	\N	\N
vice_conso_moi	0	Fumeur régulier	f	\N	\N	\N
vice_conso_moi	1	Alcool régulier	f	\N	\N	\N
vice_conso_moi	2	Fume/Bois occasionnel	f	\N	\N	\N
vice_conso_rech	0	Fumeur ok	f	\N	\N	\N
vice_conso_rech	1	Alcool régulier ok	f	\N	\N	\N
vice_conso_rech	2	Uniquement occasionnel	f	\N	\N	\N
vice_conso_rech	3	100% Sobre exigé	f	\N	\N	\N
com_integ_moi	0	Très bavard	f	\N	\N	\N
com_integ_moi	1	Préfère qu'on me questionne	f	\N	\N	\N
com_integ_moi	2	Préfère poser des Q	f	\N	\N	\N
com_integ_moi	3	Réservé	f	\N	\N	\N
com_integ_rech	0	Le centre de l'attention	f	\N	\N	\N
val_morale_moi	6	Tolérance	f	\N	\N	\N
com_drague_moi	0	Communication directe	f	\N	\N	\N
com_drague_moi	1	Communication diplomatique	f	\N	\N	\N
com_drague_rech	0	Cash et directe	f	\N	\N	\N
com_drague_rech	1	Subtile et diplomate	f	\N	\N	\N
com_ecoute_moi	0	Je préfère écouter	f	\N	\N	\N
val_morale_rech	6	L'indépendance	f	\N	\N	\N
com_ecoute_moi	2	Je préfère parler	f	\N	\N	\N
com_ecoute_rech	0	M'écoute beaucoup	f	\N	\N	\N
com_ecoute_rech	1	Parle beaucoup	f	\N	\N	\N
com_ecoute_rech	2	Soit à 50/50	f	\N	\N	\N
com_emot_moi	0	J'ai besoin de verbaliser	f	\N	\N	\N
com_emot_moi	1	J'ai de la peine à en parler	f	\N	\N	\N
com_emot_moi	2	Je n'en parle jamais	f	\N	\N	\N
com_emot_rech	0	S'ouvre facilement	f	\N	\N	\N
com_emot_rech	1	Garde une part de mystère	f	\N	\N	\N
com_emot_rech	2	Soit pragmatique (Pas trop d'émotions)	f	\N	\N	\N
vice_conso_moi	4	Ne bois jamais	f	\N	\N	\N
com_humour_moi	0	Fréquent	f	\N	\N	\N
com_humour_moi	1	Sarcastique	f	\N	\N	\N
com_humour_moi	2	Absurde	f	\N	\N	\N
com_humour_moi	3	Noir	f	\N	\N	\N
com_humour_rech	0	Bon enfant	f	\N	\N	\N
com_humour_rech	1	Piquant / Sarcastique	f	\N	\N	\N
com_humour_rech	2	Absurde	f	\N	\N	\N
com_humour_rech	3	Noir	f	\N	\N	\N
com_canal_moi	0	Parler en vrai (Pas de virtuel)	f	\N	\N	\N
com_canal_moi	1	Messages / Textos	f	\N	\N	\N
com_canal_moi	2	Appels fréquents	f	\N	\N	\N
com_canal_rech	0	Très réactif par message	f	\N	\N	\N
com_canal_rech	2	Détaché du tel, vit le moment présent	f	\N	\N	\N
com_conflit_moi	0	Je les évite à tout prix	f	\N	\N	\N
com_conflit_moi	1	J'affronte sans problème	f	\N	\N	\N
com_conflit_moi	2	J'attends qu'on m'affronte	f	\N	\N	\N
com_conflit_rech	0	Laisser couler (Pacifique)	f	\N	\N	\N
com_conflit_rech	1	Dire les choses direct	f	\N	\N	\N
com_franchis_moi	0	Je dis tout	f	\N	\N	\N
com_franchis_moi	1	J'ai de la peine à dire	f	\N	\N	\N
com_franchis_moi	2	Je n'arrive pas à être franc	f	\N	\N	\N
com_franchis_rech	0	Brutale (Toute la vérité)	f	\N	\N	\N
com_franchis_rech	1	Empathique (Dire avec tact)	f	\N	\N	\N
com_critiq_moi	0	Oui	f	\N	\N	\N
com_critiq_moi	1	Non	f	\N	\N	\N
com_critiq_rech	0	Oui	f	\N	\N	\N
com_critiq_rech	1	Non	f	\N	\N	\N
com_empathie_moi	0	Oui	f	\N	\N	\N
com_empathie_moi	1	Non	f	\N	\N	\N
com_empathie_rech	0	Essentielle	f	\N	\N	\N
com_empathie_rech	1	Bonus	f	\N	\N	\N
com_patienc_moi	0	Oui	f	\N	\N	\N
com_patienc_moi	1	Non	f	\N	\N	\N
com_patienc_rech	0	Oui	f	\N	\N	\N
com_patienc_rech	1	Non	f	\N	\N	\N
psy_confianc_moi	0	Oui	f	\N	\N	\N
psy_confianc_moi	1	Non	f	\N	\N	\N
psy_confianc_rech	0	Oui	f	\N	\N	\N
psy_confianc_rech	1	Non, ça m'intimide	f	\N	\N	\N
vice_conso_rech	4	Fumée interdite	f	\N	\N	\N
psy_anxiete_moi	0	Oui	f	\N	\N	\N
psy_anxiete_moi	1	Non	f	\N	\N	\N
psy_anxiete_rech	0	Oui	f	\N	\N	\N
psy_anxiete_rech	1	Non, je suis rassurant(e)	f	\N	\N	\N
psy_vision_moi	0	Optimiste	f	\N	\N	\N
psy_vision_moi	1	Pessimiste	f	\N	\N	\N
psy_vision_rech	0	De très positif	f	\N	\N	\N
psy_vision_rech	1	De très réaliste/pragmatique	f	\N	\N	\N
psy_curiosit_moi	0	Oui	f	\N	\N	\N
psy_curiosit_moi	1	Non	f	\N	\N	\N
psy_curiosit_rech	0	M'excite	f	\N	\N	\N
psy_curiosit_rech	1	M'indiffère	f	\N	\N	\N
psy_creativ_moi	0	Oui	f	\N	\N	\N
psy_creativ_moi	1	Non	f	\N	\N	\N
psy_creativ_rech	0	J'adore	f	\N	\N	\N
val_etudes_rech	2	Au minimum Bac +3	f	\N	\N	\N
psy_rigueur_moi	0	Rigueur	f	\N	\N	\N
psy_rigueur_moi	1	Flexibilité	f	\N	\N	\N
psy_rigueur_rech	0	Rigoureux et carré	f	\N	\N	\N
psy_rigueur_rech	1	Flexible et adaptable	f	\N	\N	\N
psy_competit_moi	0	Oui	f	\N	\N	\N
psy_competit_moi	1	Non	f	\N	\N	\N
psy_competit_rech	0	C'est stimulant	f	\N	\N	\N
psy_competit_rech	1	C'est fatiguant	f	\N	\N	\N
psy_action_moi	0	Je suis impulsif(ve)	f	\N	\N	\N
psy_action_moi	1	Je réfléchis beaucoup	f	\N	\N	\N
psy_action_rech	0	Fonceur	f	\N	\N	\N
psy_action_rech	1	Réfléchi/Prudent	f	\N	\N	\N
psy_action_rech	2	Équilibré	f	\N	\N	\N
psy_risque_moi	0	Preneur de risque	f	\N	\N	\N
psy_risque_moi	1	Prudent	f	\N	\N	\N
psy_risque_rech	0	Me pousse à oser	f	\N	\N	\N
psy_risque_rech	1	Me sécurise	f	\N	\N	\N
psy_ambition_moi	0	Oui	f	\N	\N	\N
psy_ambition_moi	1	Non	f	\N	\N	\N
psy_ambition_rech	0	C'est indispensable	f	\N	\N	\N
val_etudes_rech	3	Au minimum Bac +5	f	\N	\N	\N
psy_humilite_moi	0	Oui	f	\N	\N	\N
psy_humilite_moi	1	Non	f	\N	\N	\N
psy_humilite_rech	0	Me fait fuir	f	\N	\N	\N
psy_humilite_rech	1	Ne me dérange pas	f	\N	\N	\N
psy_humilite_rech	2	M'attire (Charisme)	f	\N	\N	\N
psy_control_moi	0	Oui	f	\N	\N	\N
psy_control_moi	1	Non	f	\N	\N	\N
psy_control_rech	0	Oui, j'aime me laisser porter	f	\N	\N	\N
psy_control_rech	1	Non, je veux l'égalité parfaite	f	\N	\N	\N
psy_adaptab_moi	0	Oui	f	\N	\N	\N
psy_adaptab_moi	1	Non	f	\N	\N	\N
psy_adaptab_rech	0	Doit être parfaite	f	\N	\N	\N
val_etudes_rech	4	Ayant un doctorat	f	\N	\N	\N
psy_spontan_moi	0	Oui	f	\N	\N	\N
psy_spontan_moi	1	Non	f	\N	\N	\N
psy_spontan_rech	0	Oui !	f	\N	\N	\N
psy_spontan_rech	1	Non, je déteste ça	f	\N	\N	\N
psy_discipli_moi	0	Oui	f	\N	\N	\N
psy_discipli_moi	1	Non	f	\N	\N	\N
psy_discipli_rech	0	Très cadré	f	\N	\N	\N
psy_discipli_rech	1	Plus léger/Bohème	f	\N	\N	\N
psy_persever_moi	0	Oui	f	\N	\N	\N
psy_persever_moi	1	Non	f	\N	\N	\N
psy_persever_rech	0	La résilience (Ne lâche rien)	f	\N	\N	\N
psy_persever_rech	1	Le lâcher-prise	f	\N	\N	\N
psy_respons_moi	0	Oui	f	\N	\N	\N
psy_respons_moi	1	Non	f	\N	\N	\N
val_but_moi	0	Créer une famille	f	\N	\N	\N
val_but_moi	1	Performer au travail	f	\N	\N	\N
val_but_moi	2	Devenir riche	f	\N	\N	\N
val_but_moi	3	Être libre	f	\N	\N	\N
val_but_moi	4	Être avec mes proches	f	\N	\N	\N
val_but_moi	5	Réussite sociale	f	\N	\N	\N
val_but_rech	0	La Famille	f	\N	\N	\N
val_but_rech	1	Le Travail / L'Argent	f	\N	\N	\N
val_but_rech	2	La Liberté / Voyages	f	\N	\N	\N
val_etudes_rech	5	Un niveau supérieur au mien	f	\N	\N	\N
val_fidelite_moi	0	1	f	\N	\N	\N
val_fidelite_moi	1	2	f	\N	\N	\N
val_fidelite_moi	2	3	f	\N	\N	\N
val_fidelite_moi	3	4	f	\N	\N	\N
val_fidelite_moi	4	5 (Fidélité absolue)	f	\N	\N	\N
val_fidelite_rech	0	1 (Relation ouverte)	f	\N	\N	\N
val_fidelite_rech	1	2	f	\N	\N	\N
val_fidelite_rech	2	3	f	\N	\N	\N
val_fidelite_rech	3	4	f	\N	\N	\N
val_fidelite_rech	4	5 (Dealbreaker si tromperie)	f	\N	\N	\N
val_honnete_moi	0	1	f	\N	\N	\N
val_honnete_moi	1	2	f	\N	\N	\N
val_honnete_moi	2	3	f	\N	\N	\N
val_honnete_moi	3	4	f	\N	\N	\N
val_honnete_moi	4	5 (Transparence totale)	f	\N	\N	\N
val_honnete_rech	0	1	f	\N	\N	\N
val_honnete_rech	1	2	f	\N	\N	\N
val_honnete_rech	2	3	f	\N	\N	\N
val_honnete_rech	3	4	f	\N	\N	\N
val_honnete_rech	4	5 (Zéro mensonge toléré)	f	\N	\N	\N
val_religion_moi	0	1 (Athée)	f	\N	\N	\N
val_religion_moi	1	2	f	\N	\N	\N
val_religion_moi	2	3	f	\N	\N	\N
val_religion_moi	3	4	f	\N	\N	\N
val_religion_moi	4	5 (Très pratiquant)	f	\N	\N	\N
val_religion_rech	0	1 (M'en fiche)	f	\N	\N	\N
val_religion_rech	1	2	f	\N	\N	\N
val_religion_rech	2	3	f	\N	\N	\N
val_religion_rech	3	4	f	\N	\N	\N
val_religion_rech	4	5 (Obligatoire)	f	\N	\N	\N
val_spirit_moi	0	1	f	\N	\N	\N
val_spirit_moi	1	2	f	\N	\N	\N
val_spirit_moi	2	3	f	\N	\N	\N
val_spirit_moi	3	4	f	\N	\N	\N
val_spirit_moi	4	5	f	\N	\N	\N
val_spirit_rech	0	Oui	f	\N	\N	\N
val_spirit_rech	1	Non	f	\N	\N	\N
val_etudes_rech	6	Un niveau inférieur au mien	f	\N	\N	\N
val_politique_moi	0	1 (Aucun)	f	\N	\N	\N
val_politique_moi	1	2	f	\N	\N	\N
val_politique_moi	2	3	f	\N	\N	\N
val_politique_moi	3	4	f	\N	\N	\N
val_politique_moi	4	5 (Militant)	f	\N	\N	\N
val_politique_rech	0	Oui, absolument	f	\N	\N	\N
val_politique_rech	1	Préférable	f	\N	\N	\N
val_politique_rech	2	Non, on en débattra	f	\N	\N	\N
val_ecolo_moi	0	1	f	\N	\N	\N
val_ecolo_moi	1	2	f	\N	\N	\N
val_ecolo_moi	2	3	f	\N	\N	\N
val_ecolo_moi	3	4	f	\N	\N	\N
val_ecolo_moi	4	5	f	\N	\N	\N
val_ecolo_rech	0	Oui, indispensable	f	\N	\N	\N
val_ecolo_rech	1	Si possible	f	\N	\N	\N
val_etudes_rech	7	Un niveau identique au mien	f	\N	\N	\N
val_tradition_moi	0	1 (Progressiste)	f	\N	\N	\N
val_tradition_moi	1	2	f	\N	\N	\N
val_tradition_moi	2	3	f	\N	\N	\N
val_tradition_moi	3	4	f	\N	\N	\N
val_tradition_moi	4	5 (Conservateur)	f	\N	\N	\N
val_tradition_rech	0	Oui	f	\N	\N	\N
val_tradition_rech	1	Non	f	\N	\N	\N
phys_taille_rech	10	Plus grand(e) que moi	f	\N	\N	\N
val_culture_moi	0	1	f	\N	\N	\N
val_culture_moi	1	2	f	\N	\N	\N
val_culture_moi	2	3	f	\N	\N	\N
val_culture_moi	3	4	f	\N	\N	\N
val_culture_moi	4	5	f	\N	\N	\N
val_culture_rech	0	Oui	f	\N	\N	\N
val_culture_rech	1	Non, ça m'intimide	f	\N	\N	\N
phys_taille_rech	11	Plus petit(e) que moi	f	\N	\N	\N
val_etudes_moi	0	Autodidacte	f	\N	\N	\N
val_etudes_moi	1	Brevet / CAP	f	\N	\N	\N
val_etudes_moi	2	Baccalauréat	f	\N	\N	\N
val_etudes_moi	3	Bac +3	f	\N	\N	\N
val_etudes_moi	4	Bac +5	f	\N	\N	\N
val_etudes_moi	5	Doctorat	f	\N	\N	\N
val_morale_moi	0	Altruisme	f	\N	\N	\N
val_morale_moi	3	Indépendance	f	\N	\N	\N
val_morale_moi	4	Loyauté	f	\N	\N	\N
val_morale_moi	5	Authenticité	f	\N	\N	\N
val_morale_rech	0	L'Altruisme	f	\N	\N	\N
val_morale_rech	1	La Loyauté	f	\N	\N	\N
val_morale_rech	2	L'Authenticité	f	\N	\N	\N
val_morale_rech	3	La Tolérance	f	\N	\N	\N
val_morale_rech	4	La Justice	f	\N	\N	\N
val_morale_rech	5	Le Respect mutuel	f	\N	\N	\N
db_relation_moi	0	Sérieuse	f	\N	\N	\N
db_relation_moi	1	Ouverte / Polyamour	f	\N	\N	\N
db_relation_moi	2	Courte / Sans lendemain	f	\N	\N	\N
db_relation_rech	0	Du sérieux exclusivement	f	\N	\N	\N
db_relation_rech	1	Une relation ouverte	f	\N	\N	\N
db_relation_rech	2	S'amuser (Sans lendemain)	f	\N	\N	\N
db_mariage_moi	0	Souhaité	f	\N	\N	\N
db_mariage_moi	1	Non souhaité	f	\N	\N	\N
db_mariage_moi	2	Déjà fait, ne veut plus	f	\N	\N	\N
db_mariage_rech	0	Oui	f	\N	\N	\N
db_mariage_rech	1	Non	f	\N	\N	\N
db_mariage_rech	2	Indécis accepté	f	\N	\N	\N
db_enfants_moi	0	Souhaités	f	\N	\N	\N
db_enfants_moi	1	Non souhaités	f	\N	\N	\N
db_enfants_moi	2	J'en ai déjà	f	\N	\N	\N
db_enfants_rech	0	Veut des enfants	f	\N	\N	\N
db_enfants_rech	1	Ne veut pas d'enfants	f	\N	\N	\N
db_enfants_rech	2	A déjà des enfants	f	\N	\N	\N
phys_taille_rech	12	Peu importe	f	\N	\N	\N
cpl_dynamiq_moi	0	Exclusive	f	\N	\N	\N
cpl_dynamiq_moi	1	Ouverte	f	\N	\N	\N
cpl_dynamiq_rech	0	Oui	f	\N	\N	\N
cpl_dynamiq_rech	1	Non	f	\N	\N	\N
cpl_fusion_moi	0	Fusionnel	f	\N	\N	\N
cpl_fusion_moi	1	Indépendant	f	\N	\N	\N
cpl_fusion_rech	0	Fait tout avec moi	f	\N	\N	\N
cpl_fusion_rech	1	Garde son indépendance	f	\N	\N	\N
cpl_affect_moi	0	Très affectueux	f	\N	\N	\N
cpl_affect_moi	1	Peu démonstratif	f	\N	\N	\N
cpl_affect_rech	0	Oui, tout le temps	f	\N	\N	\N
cpl_affect_rech	1	Non, je n'aime pas trop ça	f	\N	\N	\N
cpl_affect_rech	2	Normalement	f	\N	\N	\N
cpl_espace_moi	0	Besoin vital d'espace	f	\N	\N	\N
cpl_espace_moi	1	Besoin de temps à deux	f	\N	\N	\N
cpl_espace_rech	0	Ça me blesse	f	\N	\N	\N
cpl_espace_rech	1	C'est très sain	f	\N	\N	\N
cpl_jalous_moi	0	Jalousie élevée	f	\N	\N	\N
cpl_jalous_moi	1	Confiance élevée	f	\N	\N	\N
cpl_jalous_rech	0	C'est mignon / Ça prouve l'amour	f	\N	\N	\N
cpl_jalous_rech	1	C'est toxique, je fuis	f	\N	\N	\N
proj_prio_moi	0	Carrière prioritaire	f	\N	\N	\N
proj_prio_moi	1	Famille prioritaire	f	\N	\N	\N
proj_prio_rech	0	Sa carrière	f	\N	\N	\N
proj_prio_rech	1	Notre famille	f	\N	\N	\N
proj_prio_rech	2	L'équilibre des deux	f	\N	\N	\N
proj_statut_moi	0	Entrepreneur (Risque)	f	\N	\N	\N
proj_statut_moi	1	Salarié stable	f	\N	\N	\N
proj_statut_rech	0	Entrepreneurs ambitieux	f	\N	\N	\N
proj_statut_rech	1	Salariés stables et présents	f	\N	\N	\N
proj_lieu_moi	0	Vie urbaine (Ville)	f	\N	\N	\N
proj_lieu_moi	1	Vie rurale (Campagne)	f	\N	\N	\N
proj_lieu_rech	0	Ville (Ça bouge)	f	\N	\N	\N
proj_lieu_rech	1	Campagne (Le calme)	f	\N	\N	\N
proj_lieu_rech	2	Là où le vent nous mène	f	\N	\N	\N
proj_ancrage_moi	0	Achat immobilier (Stabilité)	f	\N	\N	\N
proj_ancrage_moi	1	Liberté géographique	f	\N	\N	\N
proj_ancrage_rech	0	S'installer / Acheter une maison	f	\N	\N	\N
proj_ancrage_rech	1	Bouger / Changer de pays souvent	f	\N	\N	\N
proj_retraite_moi	0	Retraite anticipée	f	\N	\N	\N
proj_retraite_moi	1	Voyage long terme	f	\N	\N	\N
proj_retraite_moi	2	Création d'entreprise	f	\N	\N	\N
proj_retraite_moi	3	Vie simple	f	\N	\N	\N
proj_retraite_rech	0	Prendre notre retraite tôt	f	\N	\N	\N
proj_retraite_rech	1	Voyager autour du monde	f	\N	\N	\N
proj_retraite_rech	2	Bâtir un empire	f	\N	\N	\N
proj_retraite_rech	3	Vivre simplement d'amour	f	\N	\N	\N
proj_rythme_moi	0	Recherche de stabilité	f	\N	\N	\N
proj_rythme_moi	1	Recherche d'aventure	f	\N	\N	\N
proj_rythme_rech	0	Se poser tranquillement	f	\N	\N	\N
proj_rythme_rech	1	Partir à l'aventure avec moi	f	\N	\N	\N
db_regime_moi	0	Vegan	f	\N	\N	\N
db_regime_moi	1	Végétarien	f	\N	\N	\N
db_regime_moi	2	Omnivore	f	\N	\N	\N
db_regime_rech	0	Oui, doit être Vegan/Végé	f	\N	\N	\N
db_regime_rech	1	Non, il mange ce qu'il veut	f	\N	\N	\N
db_sex_or_moi	0	Hétérosexuel(le)	f	\N	\N	\N
db_sex_or_moi	1	Homosexuel(le)	f	\N	\N	\N
db_sex_or_moi	2	Bisexuel(le)	f	\N	\N	\N
db_sex_or_moi	3	Pansexuel(le)	f	\N	\N	\N
db_sex_or_moi	4	Asexuel(le)	f	\N	\N	\N
db_sex_or_rech	0	Hétérosexuel(le)	f	\N	\N	\N
db_sex_or_rech	1	Homosexuel(le)	f	\N	\N	\N
db_sex_or_rech	2	Bisexuel(le)	f	\N	\N	\N
db_sex_or_rech	3	Pansexuel(le)	f	\N	\N	\N
db_sex_or_rech	4	Asexuel(le)	f	\N	\N	\N
genre_rech	3	Peu importe	t	\N	\N	\N
phys_silhouette_rech	4	Peu importe	t	\N	\N	\N
phys_poitrine_rech	4	Peu importe	t	\N	\N	\N
vis_forme_rech	3	Peu importe	t	\N	\N	\N
vis_symetrie_rech	1	Non (M'en fiche)	t	\N	\N	\N
vis_machoire_rech	2	Peu importe	t	\N	\N	\N
vis_menton_rech	2	Peu importe	t	\N	\N	\N
vis_pommettes_rech	2	Peu importe	t	\N	\N	\N
vis_front_rech	3	Peu importe	t	\N	\N	\N
vis_nez_rech	3	Peu importe	t	\N	\N	\N
vis_levres_rech	3	Peu importe	t	\N	\N	\N
vis_sourire_rech	2	Peu importe	t	\N	\N	\N
vis_dents_align_rech	2	Peu importe	t	\N	\N	\N
vis_dents_blanches_r	2	Peu importe	t	\N	\N	\N
vis_fossettes_rech	2	Peu importe	t	\N	\N	\N
vis_traits_rech	2	Peu importe	t	\N	\N	\N
yeux_couleur_rech	6	Peu importe	t	\N	\N	\N
yeux_forme_rech	3	Peu importe	t	\N	\N	\N
yeux_cils_rech	2	Peu importe	t	\N	\N	\N
yeux_lunettes_rech	2	Peu importe	t	\N	\N	\N
chev_longueur_rech	5	Peu importe	t	\N	\N	\N
chev_couleur_rech	6	Peu importe	t	\N	\N	\N
chev_forme_rech	4	Peu importe	t	\N	\N	\N
chev_volume_rech	2	Peu importe	t	\N	\N	\N
pil_barbe_rech	4	Peu importe	t	\N	\N	\N
pil_moustache_rech	3	Peu importe	t	\N	\N	\N
pil_corps_rech	3	Peu importe	t	\N	\N	\N
pil_sourcils_rech	3	Peu importe	t	\N	\N	\N
peau_couleur_rech	3	Peu importe	t	\N	\N	\N
peau_bronzage_rech	2	Peu importe	t	\N	\N	\N
peau_rousseur_rech	2	Peu importe	t	\N	\N	\N
peau_grains_beaute_r	2	Peu importe	t	\N	\N	\N
peau_cicatrices_rech	2	Peu importe	t	\N	\N	\N
peau_acne_rech	2	Peu importe	t	\N	\N	\N
peau_rides_rech	2	Peu importe	t	\N	\N	\N
style_vetement_rech	6	Peu importe	t	\N	\N	\N
style_tatouages_rech	2	Peu importe	t	\N	\N	\N
style_piercings_rech	2	Peu importe	t	\N	\N	\N
style_maquillage_rec	4	Peu importe	t	\N	\N	\N
style_parfum_rech	2	Peu importe	t	\N	\N	\N
life_sommeil_rech	2	Peu importe	t	\N	\N	\N
life_horaires_rech	2	Peu importe	t	\N	\N	\N
life_energie_rech	2	Équilibré / Peu importe	t	\N	\N	\N
life_orga_rech	2	Peu importe	t	\N	\N	\N
life_objets_rech	2	Peu importe	t	\N	\N	\N
life_cuisine_rech	3	Peu importe	t	\N	\N	\N
life_proprete_rech	3	Peu importe	t	\N	\N	\N
life_manuel_rech	3	M'en fiche	t	\N	\N	\N
life_job_rech	3	M'en fiche	t	\N	\N	\N
loisir_num_rech	4	Tout	t	\N	\N	\N
loisir_cult_rech	3	M'en fiche	t	\N	\N	\N
loisir_amis_rech	4	Peu importe	t	\N	\N	\N
loisir_arts_rech	4	Peu importe	t	\N	\N	\N
loisir_passion_rech	4	Peu importe	t	\N	\N	\N
loisir_benev_rech	1	Ça m'est égal	t	\N	\N	\N
voyage_aime_rech	2	Peu importe	t	\N	\N	\N
voyage_style_rech	5	Peu importe	t	\N	\N	\N
voyage_prepa_moi	3	M'en fiche des affaires	t	\N	\N	\N
voyage_prepa_rech	2	Peu importe	t	\N	\N	\N
voyage_paysage_rech	4	Tout	t	\N	\N	\N
voyage_transp_rech	3	Peu importe	t	\N	\N	\N
voyage_expat_rech	2	M'en fiche pour l'instant	t	\N	\N	\N
sport_solo_rech	5	Peu importe	t	\N	\N	\N
sport_groupe_rech	4	M'en fiche	t	\N	\N	\N
sport_freq_rech	4	Peu importe	t	\N	\N	\N
soc_extra_rech	3	Peu importe	t	\N	\N	\N
soc_intro_rech	3	Peu importe	t	\N	\N	\N
soc_reseau_rech	2	M'en fiche	t	\N	\N	\N
soc_famille_rech	2	Peu importe	t	\N	\N	\N
soc_amis_rech	2	Peu importe	t	\N	\N	\N
fin_vision_rech	3	Peu importe	t	\N	\N	\N
mob_transp_rech	2	Peu importe	t	\N	\N	\N
animaux_rech	3	Peu importe	t	\N	\N	\N
com_integ_rech	3	Peu importe	t	\N	\N	\N
com_ecoute_moi	1	Ça m'est égal	t	\N	\N	\N
com_emot_rech	3	Peu importe	t	\N	\N	\N
com_empathie_rech	2	M'en fiche	t	\N	\N	\N
psy_confianc_rech	2	Peu importe	t	\N	\N	\N
psy_creativ_rech	2	M'en fiche	t	\N	\N	\N
psy_ambition_rech	1	Ça m'est égal	t	\N	\N	\N
psy_adaptab_rech	1	N'est pas un critère clé	t	\N	\N	\N
val_but_rech	3	Peu importe, c'est son choix	t	\N	\N	\N
val_spirit_rech	2	M'en fiche	t	\N	\N	\N
val_ecolo_rech	2	M'en fiche complètement	t	\N	\N	\N
val_tradition_rech	2	Peu importe	t	\N	\N	\N
val_culture_rech	2	Peu importe	t	\N	\N	\N
db_enfants_rech	3	Peu importe	t	\N	\N	\N
proj_statut_rech	2	Peu importe	t	\N	\N	\N
db_sex_or_rech	5	Peu importe	t	\N	\N	\N
phys_poids_rech	10	Peu importe	f	\N	\N	\N
mob_transp_moi	3	Égal	f	\N	\N	\N
mob_transp_rech	0	Véhiculé (moto/voiture)	f	\N	\N	\N
val_morale_moi	1	Justice	f	\N	\N	\N
val_morale_moi	2	Respect	f	\N	\N	\N
vice_conso_moi	3	Ne fume jamais	f	\N	\N	\N
val_etudes_rech	0	Au moins le BAC	f	\N	\N	\N
val_etudes_rech	1	Non, le diplôme ne compte pas	f	\N	\N	\N
fin_comport_rech	3	Mon partenaire gère ses finances comme il/elle le souhaite	t	\N	\N	\N
com_integ_rech	1	Discret, ne monopolise pas la parole	f	\N	\N	\N
com_integ_rech	2	À l'écoute	f	\N	\N	\N
com_canal_rech	1	Fan des appels	f	\N	\N	\N
com_conflit_rech	2	Attendre que je revienne vers elle/lui	f	\N	\N	\N
psy_creativ_rech	1	Je ne recherche pas quelqu'un de créatif	f	\N	\N	\N
psy_respons_rech	0	Très responsable	f	\N	\N	\N
psy_respons_rech	1	Dans un esprit enfantin, sans toujours penser davantage	f	\N	\N	\N
\.


--
-- Data for Name: criterion_option_phrasings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.criterion_option_phrasings (criterion_key, idx, locale, phrase) FROM stdin;
genre_rech	0	fr	Je recherche un homme.
genre_rech	1	fr	Je recherche une femme.
genre_rech	2	fr	Je recherche une personne non-binaire.
phys_silhouette_rech	0	fr	Je suis attiré(e) par une silhouette mince.
phys_silhouette_rech	1	fr	Je suis attiré(e) par une silhouette athlétique.
phys_silhouette_rech	2	fr	Je suis attiré(e) par une silhouette moyenne.
phys_silhouette_rech	3	fr	Je suis attiré(e) par une silhouette ronde.
phys_poitrine_rech	0	fr	Je préfère une poitrine faible ou inexistante.
phys_poitrine_rech	1	fr	Je préfère une poitrine moyenne.
phys_poitrine_rech	2	fr	Je préfère une grande poitrine.
phys_poitrine_rech	3	fr	Cette question ne s'applique pas à moi.
vis_forme_rech	0	fr	Je suis attiré(e) par un visage ovale.
vis_forme_rech	1	fr	Je suis attiré(e) par un visage rond.
vis_forme_rech	2	fr	Je suis attiré(e) par un visage anguleux.
vis_symetrie_rech	0	fr	Je suis attiré(e) par une forte symétrie du visage.
vis_machoire_rech	0	fr	J'aime les mâchoires très marquées.
vis_machoire_rech	1	fr	Je n'aime pas les mâchoires très marquées.
vis_menton_rech	0	fr	J'aime les mentons prononcés.
vis_menton_rech	1	fr	Je n'aime pas les mentons prononcés.
vis_pommettes_rech	0	fr	J'aime les pommettes saillantes.
vis_pommettes_rech	1	fr	Je n'aime pas les pommettes saillantes.
vis_front_rech	0	fr	Je préfère un front large.
vis_front_rech	1	fr	Je préfère un front étroit.
vis_front_rech	2	fr	Je préfère un front normal.
phys_taille_moi	8	fr	Je mesure entre 186 et 190 cm.
vis_nez_moi	0	fr	J'ai le nez fin.
vis_nez_moi	1	fr	J'ai le nez large.
vis_nez_moi	2	fr	J'ai le nez normal.
vis_nez_rech	0	fr	Je préfère un nez fin.
vis_nez_rech	1	fr	Je préfère un nez large.
vis_nez_rech	2	fr	Je préfère un nez normal.
vis_levres_moi	0	fr	J'ai les lèvres fines.
vis_levres_moi	1	fr	J'ai les lèvres pulpeuses.
vis_levres_moi	2	fr	J'ai les lèvres moyennes.
vis_levres_rech	0	fr	Je suis attiré(e) par des lèvres fines.
vis_levres_rech	1	fr	Je suis attiré(e) par des lèvres pulpeuses.
vis_levres_rech	2	fr	Je suis attiré(e) par des lèvres moyennes.
vis_sourire_moi	0	fr	Mon sourire est visible sur mes photos.
vis_sourire_moi	1	fr	Je ne souris pas sur mes photos.
vis_sourire_rech	0	fr	Voir le sourire de l'autre est essentiel pour moi.
vis_sourire_rech	1	fr	Voir le sourire de l'autre n'est pas nécessaire.
phys_taille_rech	1	fr	Je recherche quelqu'un entre 145 et 154 cm.
vis_dents_align_moi	0	fr	J'ai les dents alignées.
vis_dents_align_moi	1	fr	Je n'ai pas les dents alignées.
vis_dents_align_rech	0	fr	J'attends des dents alignées.
vis_dents_align_rech	1	fr	Je n'attends pas de dents alignées.
phys_taille_rech	2	fr	Je recherche quelqu'un entre 155 et 160 cm.
vis_dents_blanches_m	0	fr	J'ai les dents très blanches.
vis_dents_blanches_m	1	fr	Je n'ai pas les dents particulièrement blanches.
vis_dents_blanches_r	0	fr	J'aime les dents très blanches.
vis_dents_blanches_r	1	fr	Je n'aime pas les dents ultra blanches.
vis_fossettes_moi	0	fr	J'ai des fossettes.
vis_fossettes_moi	1	fr	Je n'ai pas de fossettes.
vis_fossettes_rech	0	fr	Je craque pour les fossettes.
vis_fossettes_rech	1	fr	Les fossettes ne me font pas craquer.
vis_traits_moi	0	fr	J'ai les traits fins.
vis_traits_moi	1	fr	J'ai les traits marqués ou durs.
vis_traits_rech	0	fr	Je suis attiré(e) par des traits fins.
vis_traits_rech	1	fr	Je suis attiré(e) par des traits marqués.
phys_taille_rech	3	fr	Je recherche quelqu'un entre 161 et 165 cm.
yeux_couleur_moi	0	fr	J'ai les yeux bleus.
yeux_couleur_moi	1	fr	J'ai les yeux verts.
yeux_couleur_moi	2	fr	J'ai les yeux marrons.
yeux_couleur_moi	3	fr	J'ai les yeux noirs.
yeux_couleur_moi	4	fr	J'ai les yeux gris.
yeux_couleur_moi	5	fr	J'ai les yeux vairons.
yeux_couleur_rech	0	fr	Je préfère les yeux bleus.
yeux_couleur_rech	1	fr	Je préfère les yeux verts.
yeux_couleur_rech	2	fr	Je préfère les yeux marrons.
yeux_couleur_rech	3	fr	Je préfère les yeux noirs.
yeux_couleur_rech	4	fr	Je préfère les yeux gris.
yeux_couleur_rech	5	fr	Je préfère les yeux vairons.
phys_taille_rech	4	fr	Je recherche quelqu'un entre 166 et 170 cm.
yeux_forme_moi	0	fr	J'ai les yeux en amande.
yeux_forme_moi	1	fr	J'ai les yeux ronds.
yeux_forme_moi	2	fr	J'ai les yeux bridés.
yeux_forme_rech	0	fr	Je suis attiré(e) par des yeux en amande.
yeux_forme_rech	1	fr	Je suis attiré(e) par des yeux ronds.
yeux_forme_rech	2	fr	Je suis attiré(e) par des yeux bridés.
phys_taille_rech	5	fr	Je recherche quelqu'un entre 171 et 175 cm.
yeux_cils_moi	0	fr	J'ai les cils longs et marqués.
yeux_cils_moi	1	fr	Je n'ai pas les cils particulièrement marqués.
yeux_cils_rech	0	fr	J'aime les cils longs et marqués.
yeux_cils_rech	1	fr	Je n'y suis pas sensible.
phys_taille_rech	6	fr	Je recherche quelqu'un entre 176 et 180 cm.
yeux_lunettes_moi	0	fr	Je porte des lunettes.
yeux_lunettes_moi	1	fr	Je ne porte pas de lunettes.
yeux_lunettes_rech	0	fr	J'aime les porteurs de lunettes.
yeux_lunettes_rech	1	fr	Je n'aime pas les lunettes.
phys_taille_rech	7	fr	Je recherche quelqu'un entre 181 et 185 cm.
chev_longueur_moi	0	fr	J'ai les cheveux très courts ou rasés.
chev_longueur_moi	1	fr	J'ai les cheveux courts.
chev_longueur_moi	2	fr	J'ai les cheveux mi-longs.
chev_longueur_moi	3	fr	J'ai les cheveux longs.
chev_longueur_moi	4	fr	Je suis chauve.
chev_longueur_rech	0	fr	Je préfère les cheveux très courts ou rasés.
chev_longueur_rech	1	fr	Je préfère les cheveux courts.
chev_longueur_rech	2	fr	Je préfère les cheveux mi-longs.
chev_longueur_rech	3	fr	Je préfère les cheveux longs.
chev_longueur_rech	4	fr	J'aime les personnes chauves.
phys_taille_rech	8	fr	Je recherche quelqu'un entre 186 et 190 cm.
chev_couleur_moi	0	fr	J'ai les cheveux bruns.
chev_couleur_moi	1	fr	J'ai les cheveux blonds.
chev_couleur_moi	2	fr	J'ai les cheveux roux.
chev_couleur_moi	3	fr	J'ai les cheveux noirs.
chev_couleur_moi	4	fr	J'ai les cheveux gris ou blancs.
chev_couleur_moi	5	fr	J'ai une couleur de cheveux artificielle.
chev_couleur_rech	0	fr	Je préfère les cheveux bruns.
chev_couleur_rech	1	fr	Je préfère les cheveux blonds.
chev_couleur_rech	2	fr	Je préfère les cheveux roux.
chev_couleur_rech	3	fr	Je préfère les cheveux noirs.
chev_couleur_rech	4	fr	Je préfère les cheveux gris ou blancs.
chev_couleur_rech	5	fr	J'aime les colorations.
chev_forme_moi	0	fr	J'ai les cheveux bouclés.
chev_forme_moi	1	fr	J'ai les cheveux ondulés.
chev_forme_moi	2	fr	J'ai les cheveux raides.
chev_forme_moi	3	fr	J'ai les cheveux frisés ou crépus.
chev_forme_rech	0	fr	Je préfère les cheveux bouclés.
chev_forme_rech	1	fr	Je préfère les cheveux ondulés.
chev_forme_rech	2	fr	Je préfère les cheveux raides.
chev_forme_rech	3	fr	Je préfère les cheveux frisés ou crépus.
phys_poids_moi	1	fr	Je pèse entre 45 et 51 kg.
chev_volume_moi	0	fr	J'ai beaucoup de volume capillaire.
chev_volume_moi	1	fr	Je n'ai pas beaucoup de volume capillaire.
chev_volume_rech	0	fr	J'aime les chevelures volumineuses.
chev_volume_rech	1	fr	Je n'aime pas les chevelures volumineuses.
phys_poids_moi	2	fr	Je pèse entre 52 et 58 kg.
pil_barbe_moi	0	fr	Je porte une barbe longue.
pil_barbe_moi	1	fr	Je suis rasé de près.
pil_barbe_moi	2	fr	Je porte une barbe de trois jours.
pil_barbe_moi	3	fr	Je n'ai aucune pilosité au visage.
pil_barbe_rech	0	fr	Je préfère une barbe longue.
pil_barbe_rech	1	fr	Je préfère un rasage de près.
pil_barbe_rech	2	fr	Je préfère une barbe de trois jours.
pil_barbe_rech	3	fr	Je préfère un visage sans pilosité.
phys_poids_moi	3	fr	Je pèse entre 59 et 65 kg.
pil_moustache_moi	0	fr	Je porte la moustache.
pil_moustache_moi	1	fr	Je porte le bouc.
pil_moustache_moi	2	fr	Je ne porte ni moustache ni bouc.
pil_moustache_rech	0	fr	J'aime la moustache.
pil_moustache_rech	1	fr	J'aime le bouc.
pil_moustache_rech	2	fr	Je n'aime ni moustache ni bouc.
phys_poids_moi	4	fr	Je pèse entre 66 et 72 kg.
pil_corps_moi	0	fr	Je n'ai aucune pilosité corporelle ou je suis épilé(e).
pil_corps_moi	1	fr	J'ai une pilosité corporelle faible.
pil_corps_moi	2	fr	J'ai une pilosité corporelle marquée.
pil_corps_rech	0	fr	Je préfère une absence de pilosité corporelle.
pil_corps_rech	1	fr	Je préfère une pilosité corporelle faible.
pil_corps_rech	2	fr	Je préfère une pilosité corporelle marquée.
phys_poids_moi	5	fr	Je pèse entre 73 et 79 kg.
pil_sourcils_moi	0	fr	J'ai les sourcils épais.
pil_sourcils_moi	1	fr	J'ai les sourcils fins.
pil_sourcils_moi	2	fr	J'ai les sourcils tatoués.
pil_sourcils_rech	0	fr	Je préfère des sourcils épais.
pil_sourcils_rech	1	fr	Je préfère des sourcils fins.
pil_sourcils_rech	2	fr	Je préfère des sourcils tatoués.
phys_poids_moi	6	fr	Je pèse entre 80 et 86 kg.
peau_couleur_moi	0	fr	J'ai la peau claire.
peau_couleur_moi	1	fr	J'ai la peau foncée.
peau_couleur_moi	2	fr	J'ai la peau très foncée.
peau_couleur_rech	0	fr	Je suis attiré(e) par une peau claire.
peau_couleur_rech	1	fr	Je suis attiré(e) par une peau foncée.
peau_couleur_rech	2	fr	Je suis attiré(e) par une peau très foncée.
phys_poids_moi	7	fr	Je pèse entre 87 et 93 kg.
peau_bronzage_moi	0	fr	Je suis souvent bronzé(e).
peau_bronzage_moi	1	fr	Je suis rarement bronzé(e).
peau_bronzage_rech	0	fr	J'aime les teints bronzés.
peau_bronzage_rech	1	fr	Je n'aime pas les teints bronzés.
phys_poids_moi	8	fr	Je pèse entre 94 et 104 kg.
peau_rousseur_moi	0	fr	J'ai des taches de rousseur.
peau_rousseur_moi	1	fr	Je n'ai pas de taches de rousseur.
peau_rousseur_rech	0	fr	J'aime les taches de rousseur.
peau_rousseur_rech	1	fr	Je n'aime pas les taches de rousseur.
peau_grains_beaute_m	0	fr	J'ai des grains de beauté visibles.
peau_grains_beaute_m	1	fr	Je n'ai pas de grains de beauté visibles.
peau_grains_beaute_r	0	fr	J'aime les grains de beauté.
peau_grains_beaute_r	1	fr	Je n'aime pas les grains de beauté.
peau_cicatrices_moi	0	fr	J'ai des cicatrices visibles.
peau_cicatrices_moi	1	fr	Je n'ai pas de cicatrices visibles.
peau_cicatrices_rech	0	fr	Les cicatrices me dérangent.
peau_cicatrices_rech	1	fr	Je trouve que les cicatrices ont du charme.
peau_acne_rech	1	fr	Les imperfections de peau ne me dérangent pas.
peau_acne_moi	0	fr	J'ai de l'acné ou des imperfections.
peau_acne_moi	1	fr	Je n'ai pas d'imperfections particulières.
peau_acne_rech	0	fr	J'attends une peau lisse, sans imperfections.
peau_rides_moi	0	fr	J'ai des rides visibles.
peau_rides_moi	1	fr	Je n'ai pas de rides visibles.
peau_rides_rech	0	fr	Les rides me dérangent.
peau_rides_rech	1	fr	Je trouve les rides naturelles.
phys_poids_rech	1	fr	Je préfère quelqu'un entre 45 et 51 kg.
style_vetement_moi	0	fr	Mon style vestimentaire est élégant ou business.
style_vetement_moi	1	fr	Mon style vestimentaire est casual.
style_vetement_moi	2	fr	Mon style vestimentaire est streetwear ou sportif.
style_vetement_moi	3	fr	Mon style vestimentaire est bohème.
style_vetement_moi	4	fr	Mon style vestimentaire est rock ou alternatif.
style_vetement_moi	5	fr	Mon style vestimentaire est luxe.
style_vetement_rech	0	fr	Je préfère un style élégant ou business.
style_vetement_rech	1	fr	Je préfère un style casual.
style_vetement_rech	2	fr	Je préfère un style streetwear ou sportif.
style_vetement_rech	3	fr	Je préfère un style bohème.
style_vetement_rech	4	fr	Je préfère un style rock ou alternatif.
style_vetement_rech	5	fr	Je préfère un style luxe.
phys_poids_rech	2	fr	Je préfère quelqu'un entre 52 et 58 kg.
style_tatouages_moi	0	fr	J'ai des tatouages.
style_tatouages_moi	1	fr	Je n'ai pas de tatouages.
style_tatouages_rech	0	fr	J'adore les tatouages.
style_tatouages_rech	1	fr	Je n'aime pas les tatouages.
phys_poids_rech	3	fr	Je préfère quelqu'un entre 59 et 65 kg.
style_piercings_moi	0	fr	J'ai des piercings.
style_piercings_moi	1	fr	Je n'ai pas de piercings.
style_piercings_rech	0	fr	J'aime les piercings.
style_piercings_rech	1	fr	Je n'aime pas les piercings.
phys_poids_rech	4	fr	Je préfère quelqu'un entre 66 et 72 kg.
style_maquillage_moi	0	fr	Je me maquille de façon naturelle ou rarement.
style_maquillage_moi	1	fr	Je me maquille légèrement.
style_maquillage_moi	2	fr	Je me maquille de façon prononcée.
style_maquillage_moi	3	fr	Cette question ne s'applique pas à moi.
style_maquillage_rec	0	fr	Je préfère un maquillage naturel ou rare.
style_maquillage_rec	1	fr	Je préfère un maquillage léger.
style_maquillage_rec	2	fr	Je préfère un maquillage prononcé.
style_maquillage_rec	3	fr	Cette question ne s'applique pas à moi.
phys_poids_rech	5	fr	Je préfère quelqu'un entre 73 et 79 kg.
style_parfum_moi	0	fr	Je porte un parfum très marqué.
style_parfum_moi	1	fr	Je ne porte pas de parfum marqué.
style_parfum_rech	0	fr	J'aime quand l'autre est très parfumé.
style_parfum_rech	1	fr	Je n'aime pas les parfums marqués.
phys_poids_rech	6	fr	Je préfère quelqu'un entre 80 et 86 kg.
life_sommeil_moi	0	fr	Je me couche tôt et me lève tôt.
life_sommeil_moi	1	fr	Je me couche tard et me lève tard.
life_sommeil_rech	0	fr	Je préfère quelqu'un qui se couche et se lève tôt.
life_sommeil_rech	1	fr	Je préfère quelqu'un qui se couche et se lève tard.
phys_poids_rech	7	fr	Je préfère quelqu'un entre 87 et 93 kg.
life_horaires_moi	0	fr	Mes horaires de vie sont réguliers.
life_horaires_moi	1	fr	Mes horaires de vie sont flexibles.
life_horaires_rech	0	fr	J'ai besoin d'un partenaire aux horaires réguliers.
life_horaires_rech	1	fr	J'ai besoin d'un partenaire aux horaires flexibles.
phys_poids_rech	8	fr	Je préfère quelqu'un entre 94 et 104 kg.
life_energie_moi	0	fr	Au quotidien, je suis plutôt casanier(ère).
life_energie_moi	1	fr	Au quotidien, je suis très actif(ve).
life_energie_rech	0	fr	J'aime que l'autre soit casanier(ère).
life_energie_rech	1	fr	J'aime que l'autre soit très actif(ve).
life_orga_moi	0	fr	Je suis quelqu'un d'organisé.
life_orga_moi	1	fr	Je suis plutôt désordonné(e).
life_orga_rech	0	fr	Je veux vivre avec quelqu'un de très organisé.
life_orga_rech	1	fr	Je veux vivre avec quelqu'un de souple, même désordonné.
phys_taille_moi	0	fr	Je mesure moins de 145 cm.
life_objets_moi	0	fr	Avec mes affaires, je suis minimaliste.
life_objets_moi	1	fr	Avec mes affaires, je suis collectionneur(se).
life_objets_rech	0	fr	Je préfère le côté minimaliste.
life_objets_rech	1	fr	Je préfère le côté collectionneur.
phys_taille_rech	0	fr	Je recherche quelqu'un de moins de 145 cm.
life_cuisine_moi	0	fr	En cuisine, je connais les bases.
life_cuisine_moi	1	fr	Je cuisine souvent.
life_cuisine_moi	2	fr	Je commande souvent à manger.
life_cuisine_rech	0	fr	J'attends que l'autre cuisine bien.
life_cuisine_rech	1	fr	J'attends que l'autre m'aide en cuisine.
life_cuisine_rech	2	fr	Nous commanderons à manger tous les deux.
phys_poids_moi	0	fr	Je pèse moins de 45 kg.
life_proprete_moi	0	fr	Le ménage n'est pas ma priorité.
life_proprete_moi	1	fr	Je fais le ménage occasionnellement.
life_proprete_moi	2	fr	Je délègue le ménage.
life_proprete_moi	3	fr	Je suis maniaque du ménage.
life_proprete_rech	0	fr	Je veux un partenaire détendu sur le ménage.
life_proprete_rech	1	fr	Je veux un partenaire rigoureux sur le ménage.
life_proprete_rech	2	fr	Je veux un partenaire maniaque du ménage.
phys_poids_rech	0	fr	Je préfère quelqu'un de moins de 45 kg.
life_manuel_moi	0	fr	Je suis habile pour bricoler.
life_manuel_moi	1	fr	Je suis habile pour jardiner.
life_manuel_moi	2	fr	Je suis habile pour masser.
life_manuel_moi	3	fr	Je déteste les travaux manuels.
life_manuel_rech	0	fr	J'adore quand mon partenaire sait bricoler.
life_manuel_rech	1	fr	J'adore quand mon partenaire sait jardiner.
life_manuel_rech	2	fr	J'adore quand mon partenaire sait masser.
phys_taille_moi	9	fr	Je mesure plus de 191 cm.
life_ecrans_moi	0	fr	J'ai un usage intensif de mon téléphone.
life_ecrans_moi	1	fr	Je suis plutôt déconnecté(e) des écrans.
life_ecrans_moi	2	fr	J'ai un usage normal des écrans.
life_ecrans_rech	0	fr	Je supporte mal un partenaire toujours sur son téléphone.
life_ecrans_rech	1	fr	Je supporte mal un partenaire trop déconnecté.
life_ecrans_rech	2	fr	L'usage des écrans ne me pose aucun problème.
life_job_moi	0	fr	Je travaille au bureau tous les jours.
life_job_moi	1	fr	Je travaille en télétravail.
life_job_moi	2	fr	Je me déplace fréquemment pour mon travail.
life_job_moi	3	fr	Je suis stable géographiquement.
life_job_rech	0	fr	Je préfère que l'autre ait des horaires fixes.
life_job_rech	1	fr	Je préfère que l'autre ait du télétravail.
life_job_rech	2	fr	Je préfère que l'autre ait un rythme libre.
phys_taille_rech	9	fr	Je recherche quelqu'un de plus de 191 cm.
loisir_num_moi	0	fr	Je suis amateur(trice) de cinéma.
loisir_num_moi	1	fr	Je suis amateur(trice) de séries.
loisir_num_moi	2	fr	Je suis amateur(trice) de podcasts.
loisir_num_moi	3	fr	Je suis amateur(trice) de jeux vidéo.
loisir_num_rech	0	fr	J'aimerais partager le cinéma avec l'autre.
loisir_num_rech	1	fr	J'aimerais partager les séries avec l'autre.
loisir_num_rech	2	fr	J'aimerais partager les podcasts avec l'autre.
loisir_num_rech	3	fr	J'aimerais partager les jeux vidéo avec l'autre.
loisir_cult_moi	0	fr	Pour m'instruire, je privilégie la lecture.
loisir_cult_moi	1	fr	Pour m'instruire, je privilégie le théâtre.
loisir_cult_moi	2	fr	Pour m'instruire, je privilégie les musées.
loisir_cult_rech	0	fr	J'aimerais qu'on lise au calme ensemble.
loisir_cult_rech	1	fr	J'aimerais qu'on aille au théâtre ensemble.
loisir_cult_rech	2	fr	J'aimerais qu'on aille au musée ensemble.
loisir_amis_moi	0	fr	Ma soirée idéale entre amis : jeux de société.
loisir_amis_moi	1	fr	Ma soirée idéale entre amis : DIY.
loisir_amis_moi	2	fr	Ma soirée idéale entre amis : concerts ou festivals.
loisir_amis_moi	3	fr	Ma soirée idéale entre amis : boîte de nuit.
loisir_amis_moi	4	fr	Ma soirée idéale entre amis : boire un verre.
loisir_amis_rech	1	fr	Mon partenaire idéal aime faire la fête.
loisir_amis_rech	2	fr	Mon partenaire idéal aime les concerts.
loisir_amis_rech	3	fr	Mon partenaire idéal aime les bars.
phys_poids_moi	9	fr	Je pèse plus de 105 kg.
loisir_arts_moi	0	fr	Je suis captivé(e) par : danse.
loisir_arts_moi	1	fr	Je suis captivé(e) par : photographie.
loisir_arts_moi	2	fr	Je suis captivé(e) par : dessin.
loisir_arts_moi	3	fr	Je suis captivé(e) par : écriture.
loisir_arts_rech	0	fr	J'aimerais qu'il ou elle soit attiré(e) par la danse.
loisir_arts_rech	1	fr	J'aimerais qu'il ou elle soit attiré(e) par la photographie.
loisir_arts_rech	2	fr	J'aimerais qu'il ou elle soit attiré(e) par le dessin.
loisir_arts_rech	3	fr	J'aimerais qu'il ou elle soit attiré(e) par l'écriture.
phys_poids_rech	9	fr	Je préfère quelqu'un de plus de 105 kg.
loisir_passion_moi	1	fr	Je suis passionné(e) par : shopping.
loisir_passion_moi	2	fr	Je suis passionné(e) par : mode.
loisir_passion_moi	3	fr	Je suis passionné(e) par : collection d'objets.
loisir_passion_rech	0	fr	J'aimerais qu'il ou elle aime cuisiner.
loisir_passion_rech	1	fr	J'aimerais qu'il ou elle aime faire du shopping.
loisir_passion_rech	2	fr	J'aimerais qu'il ou elle aime la mode.
loisir_passion_rech	3	fr	J'aimerais qu'il ou elle aime collectionner.
loisir_amis_rech	0	fr	Mon partenaire idéal aime les activités chill à la maison.
loisir_benev_moi	0	fr	Je fais du bénévolat.
loisir_benev_moi	1	fr	Je ne fais pas de bénévolat.
loisir_benev_moi	2	fr	Je m'implique seulement si je suis défrayé(e).
loisir_benev_rech	0	fr	L'engagement associatif est un gros plus pour moi.
sport_eau_rech	0	fr	Mon partenaire doit aimer les activités aquatiques.
voyage_aime_moi	0	fr	J'aime voyager.
voyage_aime_rech	0	fr	Je veux quelqu'un qui aime voyager.
sport_eau_rech	1	fr	Je n'attends pas de faire des sports aquatiques avec mon ou ma partenaire.
voyage_style_moi	0	fr	Mes voyages préférés à deux : luxe.
voyage_style_moi	1	fr	Mes voyages préférés à deux : backpacking.
voyage_style_moi	2	fr	Mes voyages préférés à deux : culturels.
voyage_style_moi	3	fr	Mes voyages préférés à deux : nature.
voyage_style_moi	4	fr	Mes voyages préférés à deux : sportifs.
voyage_style_rech	0	fr	J'attends qu'il ou elle aime les voyages de luxe.
voyage_style_rech	1	fr	J'attends qu'il ou elle aime le backpacking.
voyage_style_rech	2	fr	J'attends qu'il ou elle aime les voyages culturels.
voyage_style_rech	3	fr	J'attends qu'il ou elle aime les voyages nature.
voyage_style_rech	4	fr	J'attends qu'il ou elle aime les voyages sportifs.
voyage_transp_rech	1	fr	Mon partenaire doit être prêt à voyager de façon écologique.
voyage_prepa_moi	0	fr	J'improvise mes voyages.
voyage_prepa_moi	1	fr	Je planifie mes voyages.
voyage_prepa_moi	2	fr	Je pars avec trois valises.
loisir_passion_moi	0	fr	Je suis passionné(e) par : cuisiner.
voyage_prepa_rech	0	fr	Je préfère un partenaire qui planifie ses voyages.
voyage_prepa_rech	1	fr	Je préfère un partenaire qui improvise ses voyages.
sport_eau_moi	2	fr	Je pratique d'autres sports aquatiques.
voyage_paysage_moi	0	fr	Les paysages que je recherche : la ville.
voyage_paysage_moi	1	fr	Les paysages que je recherche : la plage.
genre_moi	0	fr	Je suis un homme.
genre_moi	1	fr	Je suis une femme.
genre_moi	2	fr	Je suis une personne non-binaire.
phys_silhouette_moi	0	fr	J'ai une silhouette mince.
phys_silhouette_moi	1	fr	J'ai une silhouette athlétique.
phys_silhouette_moi	2	fr	J'ai une silhouette moyenne.
phys_silhouette_moi	3	fr	J'ai une silhouette ronde.
phys_taille_moi	1	fr	Je mesure entre 145 et 154 cm.
phys_poitrine_moi	0	fr	Ma poitrine est faible ou inexistante.
phys_poitrine_moi	1	fr	J'ai une poitrine moyenne.
phys_poitrine_moi	2	fr	J'ai une grande poitrine.
phys_poitrine_moi	3	fr	Cette question ne s'applique pas à moi.
phys_taille_moi	2	fr	Je mesure entre 155 et 160 cm.
vis_forme_moi	0	fr	J'ai un visage ovale.
vis_forme_moi	1	fr	J'ai un visage rond.
vis_forme_moi	2	fr	J'ai un visage anguleux.
phys_taille_moi	3	fr	Je mesure entre 161 et 165 cm.
vis_symetrie_moi	0	fr	Mon visage est très symétrique.
vis_symetrie_moi	1	fr	Mon visage n'est pas particulièrement symétrique.
phys_taille_moi	4	fr	Je mesure entre 166 et 170 cm.
vis_machoire_moi	0	fr	J'ai la mâchoire marquée.
vis_machoire_moi	1	fr	Je n'ai pas la mâchoire marquée.
phys_taille_moi	5	fr	Je mesure entre 171 et 175 cm.
vis_menton_moi	0	fr	J'ai un menton prononcé.
vis_menton_moi	1	fr	Je n'ai pas le menton prononcé.
phys_taille_moi	6	fr	Je mesure entre 176 et 180 cm.
vis_pommettes_moi	0	fr	J'ai les pommettes marquées.
vis_pommettes_moi	1	fr	Je n'ai pas les pommettes marquées.
phys_taille_moi	7	fr	Je mesure entre 181 et 185 cm.
vis_front_moi	0	fr	J'ai le front large.
vis_front_moi	1	fr	J'ai le front étroit.
voyage_paysage_moi	2	fr	Les paysages que je recherche : la montagne.
voyage_paysage_moi	3	fr	Les paysages que je recherche : la campagne.
voyage_paysage_rech	0	fr	J'aimerais qu'on parte vers la ville.
voyage_paysage_rech	1	fr	J'aimerais qu'on parte vers la plage.
voyage_paysage_rech	2	fr	J'aimerais qu'on parte vers la montagne.
voyage_paysage_rech	3	fr	J'aimerais qu'on parte vers la campagne.
voyage_aime_moi	1	fr	Je préfère rester à la maison ou dans des lieux que je maîtrise.
voyage_transp_moi	0	fr	Pour voyager, je prends le train.
voyage_transp_moi	1	fr	Pour voyager, je prends l'avion.
voyage_transp_moi	2	fr	Pour voyager, je prends la voiture.
voyage_transp_moi	3	fr	Pour voyager, je prends le vélo.
voyage_transp_moi	4	fr	Pour voyager, je prends le bateau.
voyage_transp_moi	5	fr	Je ne prends jamais l'avion.
voyage_transp_rech	0	fr	Mon partenaire doit être prêt à prendre l'avion.
voyage_transp_rech	2	fr	Mon partenaire doit être prêt à faire des roadtrips.
voyage_aime_rech	1	fr	Je veux quelqu'un de casanier ou attaché aux lieux qu'il maîtrise.
voyage_expat_moi	0	fr	L'expatriation est envisageable pour moi.
voyage_expat_moi	1	fr	Je n'envisage pas de m'expatrier.
voyage_expat_rech	0	fr	L'autre doit absolument être ouvert à l'expatriation.
voyage_expat_rech	1	fr	L'autre doit vouloir rester ici.
sport_solo_moi	0	fr	En sport individuel, je pratique musculation ou fitness.
sport_solo_moi	1	fr	En sport individuel, je pratique running.
sport_solo_moi	2	fr	En sport individuel, je pratique vélo.
sport_solo_moi	3	fr	En sport individuel, je pratique danse.
sport_solo_moi	4	fr	En sport individuel, je pratique ski.
sport_solo_rech	0	fr	J'aime quand l'autre pratique la musculation.
sport_solo_rech	1	fr	J'aime quand l'autre pratique le running.
sport_solo_rech	2	fr	J'aime quand l'autre pratique le vélo.
sport_solo_rech	3	fr	J'aime quand l'autre pratique la danse.
sport_solo_rech	4	fr	J'aime quand l'autre pratique le ski.
vis_front_moi	2	fr	J'ai le front normal.
sport_groupe_moi	0	fr	En sport collectif, je pratique yoga.
sport_groupe_moi	1	fr	En sport collectif, je pratique pilates.
sport_groupe_moi	2	fr	En sport collectif, je pratique randonnée.
sport_groupe_moi	3	fr	En sport collectif, je pratique escalade.
sport_groupe_moi	4	fr	En sport collectif, je pratique sports de combat.
sport_groupe_rech	0	fr	J'aimerais faire du yoga ou du pilates avec lui ou elle.
sport_groupe_rech	1	fr	J'aimerais faire de la randonnée avec lui ou elle.
sport_groupe_rech	2	fr	J'aimerais faire de l'escalade avec lui ou elle.
sport_groupe_rech	3	fr	J'aimerais faire des sports de combat avec lui ou elle.
sport_eau_moi	0	fr	Je pratique la natation.
sport_eau_moi	1	fr	Je pratique le surf.
sport_eau_moi	3	fr	Je déteste l'eau ou je ne sais pas nager.
sport_freq_moi	0	fr	Je suis peu ou pas sportif(ve).
sport_freq_moi	1	fr	Je fais du sport une à deux fois par semaine.
sport_freq_moi	2	fr	Je fais du sport toutes les semaines.
sport_freq_moi	3	fr	Je fais du sport presque tous les jours.
sport_freq_rech	0	fr	Je veux quelqu'un de tranquille, pas sportif.
sport_freq_rech	1	fr	Je veux quelqu'un d'un peu sportif.
sport_freq_rech	2	fr	Je veux quelqu'un de très sportif.
sport_freq_rech	3	fr	Je veux un(e) athlète acharné(e).
soc_extra_moi	0	fr	Côté sociabilité, j'ai besoin de : grand cercle social.
soc_extra_moi	1	fr	Côté sociabilité, j'ai besoin de : recevoir du monde.
soc_extra_moi	2	fr	Côté sociabilité, j'ai besoin de : rencontrer des gens.
soc_extra_moi	3	fr	Côté sociabilité, j'ai besoin de : vie nocturne active.
soc_extra_moi	4	fr	Côté sociabilité, j'ai besoin de : sorties fréquentes.
soc_extra_rech	0	fr	J'aime quand l'autre est très sociable.
soc_extra_rech	1	fr	J'aime quand l'autre aime recevoir.
soc_extra_rech	2	fr	J'aime quand l'autre est fêtard(e).
soc_intro_moi	0	fr	Côté tranquillité, je préfère : petit cercle social.
soc_intro_moi	1	fr	Côté tranquillité, je préfère : petits groupes.
soc_intro_moi	2	fr	Côté tranquillité, je préfère : besoin de solitude.
soc_intro_moi	3	fr	Côté tranquillité, je préfère : vie au calme.
soc_intro_rech	0	fr	J'apprécie quand l'autre est solitaire et calme.
soc_intro_rech	1	fr	J'apprécie quand l'autre préfère les petits comités.
soc_intro_rech	2	fr	J'apprécie quand l'autre est indépendant(e).
animaux_moi	5	fr	Je déteste les animaux.
soc_reseau_moi	0	fr	Mon réseau professionnel compte beaucoup pour moi.
soc_reseau_moi	1	fr	Mon réseau professionnel n'est pas une priorité.
soc_reseau_rech	0	fr	J'admire les gens très « réseau ».
soc_reseau_rech	1	fr	Je n'admire pas particulièrement les gens très « réseau ».
animaux_moi	6	fr	Je n'aime quasiment que les chiens et les chats.
soc_famille_moi	0	fr	Je suis proche de ma famille.
soc_famille_moi	1	fr	Je ne suis pas particulièrement proche de ma famille.
soc_famille_rech	0	fr	Je cherche quelqu'un de proche de sa famille.
soc_famille_rech	1	fr	Je cherche quelqu'un d'indépendant de sa famille.
db_relation_moi	3	fr	Je recherche une amitié.
soc_amis_moi	0	fr	Je suis proche de mes amis.
soc_amis_moi	1	fr	Je ne suis pas particulièrement proche de mes amis.
soc_amis_rech	0	fr	J'aime l'esprit bande d'amis.
soc_amis_rech	1	fr	Je préfère que le couple passe avant les amis.
db_relation_rech	3	fr	Je suis ouvert(e) à tout type de rencontre.
fin_comport_moi	0	fr	Avec mon argent, je suis dépensier(ère).
fin_comport_moi	1	fr	Avec mon argent, je suis économe.
fin_comport_moi	2	fr	Avec mon argent, je suis investisseur(se).
fin_comport_moi	3	fr	J'ai le goût du luxe.
fin_comport_rech	0	fr	Je supporterais mal un partenaire trop radin.
fin_comport_rech	1	fr	Je supporterais mal un partenaire trop flambeur.
fin_comport_rech	2	fr	Je supporterais mal un partenaire sans ambition financière.
db_relation_rech	4	fr	Je cherche une amitié.
fin_vision_moi	0	fr	Je recherche la stabilité financière.
fin_vision_moi	1	fr	Je suis prêt(e) à prendre des risques financiers.
fin_vision_moi	2	fr	Je privilégie une consommation responsable.
fin_vision_rech	0	fr	Je cherche quelqu'un qui vise la sécurité financière.
fin_vision_rech	1	fr	Je cherche quelqu'un qui vise la prise de risque.
fin_vision_rech	2	fr	Je cherche quelqu'un qui vise une consommation responsable.
mob_transp_moi	4	fr	Je me déplace en moto ou en vélomoteur.
mob_transp_moi	0	fr	Je me déplace en transports publics.
mob_transp_moi	1	fr	Je me déplace en voiture.
mob_transp_moi	2	fr	Je me déplace à vélo.
mob_transp_rech	1	fr	Mon partenaire doit se déplacer de façon écologique.
psy_vision_moi	2	fr	Je suis réaliste.
animaux_moi	0	fr	Je suis gaga des animaux des autres.
animaux_moi	1	fr	J'ai ou je veux des animaux.
animaux_moi	2	fr	Je suis allergique aux animaux.
animaux_moi	3	fr	J'ai peur des animaux.
animaux_moi	4	fr	J'aime les animaux atypiques.
animaux_rech	0	fr	Un partenaire avec des animaux, c'est génial.
animaux_rech	1	fr	Un partenaire avec des animaux, c'est non.
animaux_rech	2	fr	J'accepte seulement les chats et les chiens.
psy_vision_rech	2	fr	La vision de la vie de l'autre m'importe peu.
vice_conso_moi	0	fr	Je fume régulièrement.
vice_conso_moi	1	fr	Je bois régulièrement.
vice_conso_moi	2	fr	Je fume ou bois occasionnellement.
vice_conso_rech	0	fr	J'accepte que l'autre fume.
vice_conso_rech	1	fr	J'accepte une consommation régulière d'alcool.
vice_conso_rech	2	fr	Je n'accepte qu'une consommation occasionnelle.
vice_conso_rech	3	fr	J'exige quelqu'un de totalement sobre.
com_integ_moi	0	fr	Pour m'intégrer, je suis très bavard(e).
com_integ_moi	1	fr	Je préfère qu'on vienne me questionner.
com_integ_moi	2	fr	Je préfère poser des questions.
com_integ_moi	3	fr	Je reste plutôt réservé(e).
com_integ_rech	0	fr	J'aime que l'autre soit le centre de l'attention.
val_morale_moi	6	fr	La tolérance est une de mes valeurs fortes.
com_drague_moi	0	fr	Pour draguer, je suis direct(e).
com_drague_moi	1	fr	Pour draguer, je suis diplomate.
com_drague_rech	0	fr	J'aime me faire aborder de façon cash et directe.
com_drague_rech	1	fr	J'aime me faire aborder de façon subtile et diplomate.
com_ecoute_moi	0	fr	En discussion, je préfère écouter.
val_morale_rech	6	fr	Je recherche avant tout l'indépendance.
com_ecoute_moi	2	fr	En discussion, je préfère parler.
com_ecoute_rech	0	fr	J'ai besoin de quelqu'un qui m'écoute beaucoup.
com_ecoute_rech	1	fr	J'ai besoin de quelqu'un qui parle beaucoup.
com_ecoute_rech	2	fr	J'ai besoin d'un équilibre à parts égales.
com_emot_moi	0	fr	J'ai besoin de verbaliser mes émotions.
com_emot_moi	1	fr	J'ai de la peine à parler de mes émotions.
com_emot_moi	2	fr	Je ne parle jamais de mes émotions.
com_emot_rech	0	fr	Je veux que mon partenaire s'ouvre facilement.
com_emot_rech	1	fr	Je veux que mon partenaire garde une part de mystère.
com_emot_rech	2	fr	Je veux que mon partenaire soit pragmatique, peu démonstratif.
vice_conso_moi	4	fr	Je ne bois jamais.
com_humour_moi	0	fr	Mon humour est fréquent.
com_humour_moi	1	fr	Mon humour est sarcastique.
com_humour_moi	2	fr	Mon humour est absurde.
com_humour_moi	3	fr	Mon humour est noir.
com_humour_rech	0	fr	L'humour qui me fait rire est bon enfant.
com_humour_rech	1	fr	L'humour qui me fait rire est piquant ou sarcastique.
com_humour_rech	2	fr	L'humour qui me fait rire est absurde.
com_humour_rech	3	fr	L'humour qui me fait rire est noir.
com_canal_moi	0	fr	Je préfère parler en vrai plutôt qu'à distance.
com_canal_moi	1	fr	Je préfère les messages et les textos.
com_canal_moi	2	fr	Je préfère les appels fréquents.
com_canal_rech	0	fr	J'attends quelqu'un de très réactif par message.
com_canal_rech	2	fr	J'attends quelqu'un de détaché du téléphone, qui vit le moment présent.
com_conflit_moi	0	fr	J'évite les conflits à tout prix.
com_conflit_moi	1	fr	J'affronte les conflits sans problème.
com_conflit_moi	2	fr	J'attends qu'on vienne me confronter.
com_conflit_rech	0	fr	Lors d'une dispute, l'autre doit laisser couler.
com_conflit_rech	1	fr	Lors d'une dispute, l'autre doit dire les choses directement.
com_franchis_moi	0	fr	Je dis tout ce que je pense.
com_franchis_moi	1	fr	J'ai de la peine à dire les choses.
com_franchis_moi	2	fr	Je n'arrive pas à être franc(he).
com_franchis_rech	0	fr	J'attends une honnêteté brutale, toute la vérité.
com_franchis_rech	1	fr	J'attends une honnêteté empathique, dite avec tact.
com_critiq_moi	0	fr	Je suis sensible aux critiques.
com_critiq_moi	1	fr	Je ne suis pas sensible aux critiques.
com_critiq_rech	0	fr	Avoir un partenaire susceptible me dérange.
com_critiq_rech	1	fr	Avoir un partenaire susceptible ne me dérange pas.
com_empathie_moi	0	fr	Je fais preuve d'empathie.
com_empathie_moi	1	fr	Je ne suis pas particulièrement empathique.
com_empathie_rech	0	fr	L'empathie de l'autre est essentielle.
com_empathie_rech	1	fr	L'empathie de l'autre est un bonus.
com_patienc_moi	0	fr	Je suis quelqu'un de patient.
com_patienc_moi	1	fr	Je ne suis pas très patient(e).
com_patienc_rech	0	fr	J'ai besoin de quelqu'un de patient avec moi.
com_patienc_rech	1	fr	Je n'ai pas besoin de quelqu'un de particulièrement patient.
psy_confianc_moi	0	fr	J'ai confiance en moi.
psy_confianc_moi	1	fr	Je manque parfois de confiance en moi.
psy_confianc_rech	0	fr	Un partenaire sûr de lui m'attire.
psy_confianc_rech	1	fr	Un partenaire sûr de lui m'intimide.
vice_conso_rech	4	fr	Je n'accepte pas la fumée.
psy_anxiete_moi	0	fr	Je suis de nature anxieuse.
psy_anxiete_moi	1	fr	Je ne suis pas de nature anxieuse.
psy_anxiete_rech	0	fr	Aider un partenaire anxieux me fait peur.
psy_anxiete_rech	1	fr	Je sais être rassurant(e) face à l'anxiété.
psy_vision_moi	0	fr	Je suis optimiste.
psy_vision_moi	1	fr	Je suis pessimiste.
psy_vision_rech	0	fr	Je veux m'entourer de quelqu'un de très positif.
psy_vision_rech	1	fr	Je veux m'entourer de quelqu'un de très réaliste et pragmatique.
psy_curiosit_moi	0	fr	Je suis curieux(se).
psy_curiosit_moi	1	fr	Je ne suis pas particulièrement curieux(se).
psy_curiosit_rech	0	fr	La curiosité intellectuelle de l'autre m'excite.
psy_curiosit_rech	1	fr	La curiosité intellectuelle de l'autre m'indiffère.
psy_creativ_moi	0	fr	Je suis créatif(ve).
psy_creativ_moi	1	fr	Je ne suis pas particulièrement créatif(ve).
psy_creativ_rech	0	fr	J'adore un esprit artistique chez l'autre.
val_etudes_rech	2	fr	Je recherche au minimum un Bac +3.
psy_rigueur_moi	0	fr	Je fais preuve de rigueur.
psy_rigueur_moi	1	fr	Je fais preuve de flexibilité.
psy_rigueur_rech	0	fr	J'aime que l'autre soit rigoureux et carré.
psy_rigueur_rech	1	fr	J'aime que l'autre soit flexible et adaptable.
psy_competit_moi	0	fr	Je suis compétitif(ve).
psy_competit_moi	1	fr	Je ne suis pas compétitif(ve).
psy_competit_rech	0	fr	Un partenaire qui veut toujours gagner, c'est stimulant.
psy_competit_rech	1	fr	Un partenaire qui veut toujours gagner, c'est fatigant.
psy_action_moi	0	fr	Avant d'agir, je suis impulsif(ve).
psy_action_moi	1	fr	Avant d'agir, je réfléchis beaucoup.
psy_action_rech	0	fr	Je préfère un caractère fonceur.
psy_action_rech	1	fr	Je préfère un caractère réfléchi et prudent.
psy_action_rech	2	fr	Je préfère un caractère équilibré.
psy_risque_moi	0	fr	Face au risque, je suis preneur(se).
psy_risque_moi	1	fr	Face au risque, je suis prudent(e).
psy_risque_rech	0	fr	J'ai besoin de quelqu'un qui me pousse à oser.
psy_risque_rech	1	fr	J'ai besoin de quelqu'un qui me sécurise.
psy_ambition_moi	0	fr	J'ai de l'ambition.
psy_ambition_moi	1	fr	Je n'ai pas particulièrement d'ambition.
psy_ambition_rech	0	fr	L'ambition chez l'autre est indispensable.
val_etudes_rech	3	fr	Je recherche au minimum un Bac +5.
psy_humilite_moi	0	fr	Je fais preuve d'humilité.
psy_humilite_moi	1	fr	Je ne me définis pas par l'humilité.
psy_humilite_rech	0	fr	Quelqu'un qui se vante beaucoup me fait fuir.
psy_humilite_rech	1	fr	Quelqu'un qui se vante beaucoup ne me dérange pas.
psy_humilite_rech	2	fr	Quelqu'un qui se vante beaucoup m'attire, j'y vois du charisme.
psy_control_moi	0	fr	J'ai un grand besoin de contrôle.
psy_control_moi	1	fr	Je n'ai pas de besoin particulier de contrôle.
psy_control_rech	0	fr	J'accepte que l'autre dirige souvent, j'aime me laisser porter.
psy_control_rech	1	fr	Je veux une égalité parfaite, sans que l'autre dirige.
psy_adaptab_moi	0	fr	Je m'adapte facilement.
psy_adaptab_moi	1	fr	J'ai besoin de temps pour m'adapter.
psy_adaptab_rech	0	fr	L'adaptabilité de mon partenaire doit être parfaite.
val_etudes_rech	4	fr	Je recherche quelqu'un ayant un doctorat.
psy_spontan_moi	0	fr	Je suis très spontané(e).
psy_spontan_moi	1	fr	Je suis peu spontané(e).
psy_spontan_rech	0	fr	J'adore les surprises de dernière minute.
psy_spontan_rech	1	fr	Je déteste les surprises de dernière minute.
psy_discipli_moi	0	fr	Je suis quelqu'un de discipliné.
psy_discipli_moi	1	fr	Je ne suis pas très discipliné(e).
psy_discipli_rech	0	fr	Je cherche un partenaire très cadré.
psy_discipli_rech	1	fr	Je cherche un partenaire plus léger, bohème.
psy_persever_moi	0	fr	Ma persévérance est forte.
psy_persever_moi	1	fr	Je lâche prise assez facilement.
psy_persever_rech	0	fr	J'apprécie la résilience, quelqu'un qui ne lâche rien.
psy_persever_rech	1	fr	J'apprécie le lâcher-prise.
psy_respons_moi	0	fr	J'ai un grand sens des responsabilités.
psy_respons_moi	1	fr	Je ne me définis pas par le sens des responsabilités.
val_but_moi	0	fr	Je vis avant tout pour créer une famille.
val_but_moi	1	fr	Je vis avant tout pour performer au travail.
val_but_moi	2	fr	Je vis avant tout pour devenir riche.
val_but_moi	3	fr	Je vis avant tout pour être libre.
val_but_moi	4	fr	Je vis avant tout pour être avec mes proches.
val_but_moi	5	fr	Je vis avant tout pour la réussite sociale.
val_but_rech	0	fr	Mon ou ma partenaire devrait viser la famille.
val_but_rech	1	fr	Mon ou ma partenaire devrait viser le travail et l'argent.
val_but_rech	2	fr	Mon ou ma partenaire devrait viser la liberté et les voyages.
val_etudes_rech	5	fr	Je recherche un niveau supérieur au mien.
val_fidelite_moi	0	fr	La fidélité n'est pas un cadre que je m'impose.
val_fidelite_moi	1	fr	Je suis assez souple sur la fidélité.
val_fidelite_moi	2	fr	Je suis plutôt fidèle.
val_fidelite_moi	3	fr	Je suis très fidèle.
val_fidelite_moi	4	fr	La fidélité est absolue pour moi.
val_fidelite_rech	0	fr	J'accepte une relation ouverte.
val_fidelite_rech	1	fr	Je suis souple sur l'exclusivité.
val_fidelite_rech	2	fr	J'attends une exclusivité modérée.
val_fidelite_rech	3	fr	J'attends une forte exclusivité.
val_fidelite_rech	4	fr	Une tromperie serait rédhibitoire.
val_honnete_moi	0	fr	Je m'autorise des arrangements avec la vérité.
val_honnete_moi	1	fr	Je ne dis pas toujours tout.
val_honnete_moi	2	fr	Je suis plutôt honnête.
val_honnete_moi	3	fr	Je suis très honnête.
val_honnete_moi	4	fr	La transparence est totale chez moi.
val_honnete_rech	0	fr	Je suis très souple sur l'honnêteté.
val_honnete_rech	1	fr	Je suis assez souple sur l'honnêteté.
val_honnete_rech	2	fr	J'attends une honnêteté modérée.
val_honnete_rech	3	fr	J'attends une grande honnêteté.
val_honnete_rech	4	fr	Je ne tolère aucun mensonge.
val_religion_moi	0	fr	Je suis athée.
val_religion_moi	1	fr	La religion tient une place très limitée dans ma vie.
val_religion_moi	2	fr	La religion tient une place modérée dans ma vie.
val_religion_moi	3	fr	La religion tient une place importante dans ma vie.
val_religion_moi	4	fr	Je suis très pratiquant(e).
val_religion_rech	0	fr	La croyance de l'autre m'importe peu.
val_religion_rech	1	fr	La croyance de l'autre compte un peu.
val_religion_rech	2	fr	La croyance de l'autre compte modérément.
val_religion_rech	3	fr	La croyance de l'autre compte beaucoup.
val_religion_rech	4	fr	La croyance de l'autre est obligatoire pour moi.
val_spirit_moi	0	fr	La spiritualité ne me parle pas.
val_spirit_moi	1	fr	La spiritualité m'intéresse peu.
val_spirit_moi	2	fr	Je suis modérément intéressé(e) par la spiritualité.
val_spirit_moi	3	fr	La spiritualité compte pour moi.
val_spirit_moi	4	fr	La spiritualité tient une grande place dans ma vie.
val_spirit_rech	0	fr	L'autre doit être spirituel.
val_spirit_rech	1	fr	L'autre ne doit pas être spirituel.
val_etudes_rech	6	fr	Je recherche un niveau inférieur au mien.
val_politique_moi	0	fr	Je n'ai aucun engagement politique.
val_politique_moi	1	fr	Je suis peu engagé(e) politiquement.
val_politique_moi	2	fr	Je suis modérément engagé(e) politiquement.
val_politique_moi	3	fr	Je suis engagé(e) politiquement.
val_politique_moi	4	fr	Je suis militant(e).
val_politique_rech	0	fr	L'autre doit absolument avoir un engagement politique.
val_politique_rech	1	fr	Un engagement politique chez l'autre est préférable.
val_politique_rech	2	fr	L'engagement politique n'a pas d'importance, on en débattra.
val_ecolo_moi	0	fr	L'écologie n'oriente pas mes choix.
val_ecolo_moi	1	fr	L'écologie oriente peu mes choix.
val_ecolo_moi	2	fr	L'écologie oriente modérément mes choix.
val_ecolo_moi	3	fr	L'écologie oriente beaucoup mes choix.
val_ecolo_moi	4	fr	L'écologie est au cœur de mes choix.
val_ecolo_rech	0	fr	Je veux un partenaire écologiste, c'est indispensable.
val_ecolo_rech	1	fr	Un partenaire écologiste, si possible.
val_etudes_rech	7	fr	Je recherche un niveau identique au mien.
val_tradition_moi	0	fr	Je suis progressiste.
val_tradition_moi	1	fr	Je suis plutôt progressiste.
val_tradition_moi	2	fr	Je suis partagé(e) entre tradition et modernité.
val_tradition_moi	3	fr	Je suis plutôt attaché(e) aux traditions.
val_tradition_moi	4	fr	Je suis conservateur(trice).
val_tradition_rech	0	fr	Mon partenaire doit respecter les traditions.
val_tradition_rech	1	fr	Mon partenaire ne doit pas être attaché aux traditions.
phys_taille_rech	10	fr	Je préfère quelqu'un de plus grand(e) que moi.
val_culture_moi	0	fr	La culture ne m'attire pas particulièrement.
val_culture_moi	1	fr	Je m'intéresse peu à la culture.
val_culture_moi	2	fr	Je m'intéresse modérément à la culture.
val_culture_moi	3	fr	Je m'intéresse beaucoup à la culture.
val_culture_moi	4	fr	La culture tient une grande place dans ma vie.
val_culture_rech	0	fr	Je cherche quelqu'un de très cultivé.
val_culture_rech	1	fr	Quelqu'un de très cultivé m'intimide.
phys_taille_rech	11	fr	Je préfère quelqu'un de plus petit(e) que moi.
val_etudes_moi	0	fr	Je suis autodidacte.
val_etudes_moi	1	fr	J'ai un brevet ou un CAP.
val_etudes_moi	2	fr	J'ai le baccalauréat.
val_etudes_moi	3	fr	J'ai un Bac +3.
val_etudes_moi	4	fr	J'ai un Bac +5.
val_etudes_moi	5	fr	J'ai un doctorat.
val_morale_moi	0	fr	L'altruisme est une de mes valeurs fortes.
val_morale_moi	3	fr	L'indépendance est une de mes valeurs fortes.
val_morale_moi	4	fr	La loyauté est une de mes valeurs fortes.
val_morale_moi	5	fr	L'authenticité est une de mes valeurs fortes.
val_morale_rech	0	fr	Je recherche avant tout l'altruisme.
val_morale_rech	1	fr	Je recherche avant tout la loyauté.
val_morale_rech	2	fr	Je recherche avant tout l'authenticité.
val_morale_rech	3	fr	Je recherche avant tout la tolérance.
val_morale_rech	4	fr	Je recherche avant tout la justice.
val_morale_rech	5	fr	Je recherche avant tout le respect mutuel.
db_relation_moi	0	fr	J'envisage une relation sérieuse.
db_relation_moi	1	fr	J'envisage une relation ouverte ou du polyamour.
db_relation_moi	2	fr	J'envisage une relation courte, sans lendemain.
db_relation_rech	0	fr	Je cherche quelqu'un qui veut du sérieux exclusivement.
db_relation_rech	1	fr	Je cherche quelqu'un qui veut une relation ouverte.
db_relation_rech	2	fr	Je cherche quelqu'un qui veut s'amuser, sans lendemain.
db_mariage_moi	0	fr	Je souhaite me marier.
db_mariage_moi	1	fr	Je ne souhaite pas me marier.
db_mariage_moi	2	fr	J'ai déjà été marié(e) et ne souhaite pas recommencer.
db_mariage_rech	0	fr	Mon partenaire doit vouloir se marier un jour.
db_mariage_rech	1	fr	Mon partenaire ne doit pas vouloir se marier.
db_mariage_rech	2	fr	J'accepte quelqu'un d'indécis sur le mariage.
db_enfants_moi	0	fr	Je souhaite des enfants.
db_enfants_moi	1	fr	Je ne souhaite pas d'enfants.
db_enfants_moi	2	fr	J'ai déjà des enfants.
db_enfants_rech	0	fr	Je veux rencontrer quelqu'un qui veut des enfants.
db_enfants_rech	1	fr	Je veux rencontrer quelqu'un qui ne veut pas d'enfants.
db_enfants_rech	2	fr	Je veux rencontrer quelqu'un qui a déjà des enfants.
phys_taille_rech	12	fr	La taille m'importe peu.
cpl_dynamiq_moi	0	fr	Ma dynamique de couple idéale est exclusive.
cpl_dynamiq_moi	1	fr	Ma dynamique de couple idéale est ouverte.
cpl_dynamiq_rech	0	fr	J'accepterais que mon partenaire voie d'autres personnes.
cpl_dynamiq_rech	1	fr	Je n'accepterais pas que mon partenaire voie d'autres personnes.
cpl_fusion_moi	0	fr	Dans le couple, je suis fusionnel(le).
cpl_fusion_moi	1	fr	Dans le couple, je reste indépendant(e).
cpl_fusion_rech	0	fr	Je cherche quelqu'un qui fait tout avec moi.
cpl_fusion_rech	1	fr	Je cherche quelqu'un qui garde son indépendance.
cpl_affect_moi	0	fr	Je suis très affectueux(se).
cpl_affect_moi	1	fr	Je suis peu démonstratif(ve).
cpl_affect_rech	0	fr	J'aime que l'autre soit câlin et tactile en permanence.
cpl_affect_rech	1	fr	Je n'aime pas trop les démonstrations d'affection.
cpl_affect_rech	2	fr	J'aime une affection normale, sans excès.
cpl_espace_moi	0	fr	J'ai un besoin vital d'espace personnel.
cpl_espace_moi	1	fr	J'ai besoin de temps à deux.
cpl_espace_rech	0	fr	Si mon partenaire part seul en week-end, ça me blesse.
cpl_espace_rech	1	fr	Si mon partenaire part seul en week-end, je trouve ça très sain.
cpl_jalous_moi	0	fr	Ma jalousie est plutôt élevée.
cpl_jalous_moi	1	fr	Je fais preuve d'une grande confiance.
cpl_jalous_rech	0	fr	Un partenaire un peu jaloux, je trouve ça mignon.
cpl_jalous_rech	1	fr	Un partenaire jaloux, je trouve ça toxique et je fuis.
proj_prio_moi	0	fr	Ma carrière est prioritaire.
proj_prio_moi	1	fr	Ma famille est prioritaire.
proj_prio_rech	0	fr	J'aimerais que sa priorité soit sa carrière.
proj_prio_rech	1	fr	J'aimerais que sa priorité soit notre famille.
proj_prio_rech	2	fr	J'aimerais qu'il ou elle trouve l'équilibre entre les deux.
proj_statut_moi	0	fr	Je travaille ou veux travailler comme entrepreneur(se).
proj_statut_moi	1	fr	Je travaille ou veux travailler comme salarié(e) stable.
proj_statut_rech	0	fr	J'admire les partenaires entrepreneurs et ambitieux.
proj_statut_rech	1	fr	J'admire les partenaires salariés, stables et présents.
proj_lieu_moi	0	fr	Je veux vivre en ville.
proj_lieu_moi	1	fr	Je veux vivre à la campagne.
proj_lieu_rech	0	fr	On devra se mettre d'accord pour vivre en ville.
proj_lieu_rech	1	fr	On devra se mettre d'accord pour vivre à la campagne.
proj_lieu_rech	2	fr	On ira là où le vent nous mène.
proj_ancrage_moi	0	fr	Mon but est d'acheter et de me stabiliser.
proj_ancrage_moi	1	fr	Mon but est de garder ma liberté géographique.
proj_ancrage_rech	0	fr	J'ai besoin qu'il ou elle ait envie de s'installer et d'acheter.
proj_ancrage_rech	1	fr	J'ai besoin qu'il ou elle ait envie de bouger et de changer de pays.
proj_retraite_moi	0	fr	Mon plan à long terme est une retraite anticipée.
proj_retraite_moi	1	fr	Mon plan à long terme est de voyager longuement.
proj_retraite_moi	2	fr	Mon plan à long terme est de créer une entreprise.
proj_retraite_moi	3	fr	Mon plan à long terme est de vivre simplement.
proj_retraite_rech	0	fr	L'idéal de vie à deux serait de prendre notre retraite tôt.
proj_retraite_rech	1	fr	L'idéal de vie à deux serait de voyager autour du monde.
proj_retraite_rech	2	fr	L'idéal de vie à deux serait de bâtir un empire.
proj_retraite_rech	3	fr	L'idéal de vie à deux serait de vivre simplement d'amour.
proj_rythme_moi	0	fr	Je recherche avant tout la stabilité.
proj_rythme_moi	1	fr	Je recherche avant tout l'aventure.
proj_rythme_rech	0	fr	Mon ou ma complice devra être prêt(e) à se poser tranquillement.
proj_rythme_rech	1	fr	Mon ou ma complice devra être prêt(e) à partir à l'aventure avec moi.
db_regime_moi	0	fr	Je suis vegan.
db_regime_moi	1	fr	Je suis végétarien(ne).
db_regime_moi	2	fr	Je suis omnivore.
db_regime_rech	0	fr	Mon partenaire doit être vegan ou végétarien.
db_regime_rech	1	fr	Mon partenaire mange ce qu'il veut.
db_sex_or_moi	0	fr	Je suis hétérosexuel(le).
db_sex_or_moi	1	fr	Je suis homosexuel(le).
db_sex_or_moi	2	fr	Je suis bisexuel(le).
db_sex_or_moi	3	fr	Je suis pansexuel(le).
db_sex_or_moi	4	fr	Je suis asexuel(le).
db_sex_or_rech	0	fr	Je cherche un(e) partenaire hétérosexuel(le).
db_sex_or_rech	1	fr	Je cherche un(e) partenaire homosexuel(le).
db_sex_or_rech	2	fr	Je cherche un(e) partenaire bisexuel(le).
db_sex_or_rech	3	fr	Je cherche un(e) partenaire pansexuel(le).
db_sex_or_rech	4	fr	Je cherche un(e) partenaire asexuel(le).
genre_rech	3	fr	Le genre m'importe peu.
phys_silhouette_rech	4	fr	La silhouette m'importe peu.
phys_poitrine_rech	4	fr	Le volume de poitrine m'importe peu.
vis_forme_rech	3	fr	La forme du visage m'importe peu.
vis_symetrie_rech	1	fr	La symétrie du visage m'importe peu.
vis_machoire_rech	2	fr	La mâchoire m'importe peu.
vis_menton_rech	2	fr	Le menton m'importe peu.
vis_pommettes_rech	2	fr	Les pommettes m'importent peu.
vis_front_rech	3	fr	Le front m'importe peu.
vis_nez_rech	3	fr	Le nez m'importe peu.
vis_levres_rech	3	fr	Les lèvres m'importent peu.
vis_sourire_rech	2	fr	Le sourire sur les photos m'importe peu.
vis_dents_align_rech	2	fr	L'alignement des dents m'importe peu.
vis_dents_blanches_r	2	fr	La blancheur des dents m'importe peu.
vis_fossettes_rech	2	fr	Les fossettes m'importent peu.
vis_traits_rech	2	fr	Les traits du visage m'importent peu.
yeux_couleur_rech	6	fr	La couleur des yeux m'importe peu.
yeux_forme_rech	3	fr	La forme des yeux m'importe peu.
yeux_cils_rech	2	fr	Les cils m'importent peu.
yeux_lunettes_rech	2	fr	Les lunettes m'importent peu.
chev_longueur_rech	5	fr	La longueur des cheveux m'importe peu.
chev_couleur_rech	6	fr	La couleur des cheveux m'importe peu.
chev_forme_rech	4	fr	La forme des cheveux m'importe peu.
chev_volume_rech	2	fr	Le volume capillaire m'importe peu.
pil_barbe_rech	4	fr	La barbe m'importe peu.
pil_moustache_rech	3	fr	Cela m'importe peu.
pil_corps_rech	3	fr	La pilosité corporelle m'importe peu.
pil_sourcils_rech	3	fr	Les sourcils m'importent peu.
peau_couleur_rech	3	fr	La couleur de peau m'importe peu.
peau_bronzage_rech	2	fr	Le bronzage m'importe peu.
peau_rousseur_rech	2	fr	Les taches de rousseur m'importent peu.
peau_grains_beaute_r	2	fr	Les grains de beauté m'importent peu.
peau_cicatrices_rech	2	fr	Les cicatrices m'importent peu.
peau_acne_rech	2	fr	Les imperfections de peau m'importent peu.
peau_rides_rech	2	fr	Les rides m'importent peu.
style_vetement_rech	6	fr	Le style vestimentaire m'importe peu.
style_tatouages_rech	2	fr	Les tatouages m'importent peu.
style_piercings_rech	2	fr	Les piercings m'importent peu.
style_maquillage_rec	4	fr	Le maquillage m'importe peu.
style_parfum_rech	2	fr	Le parfum m'importe peu.
life_sommeil_rech	2	fr	Le rythme de sommeil m'importe peu.
life_horaires_rech	2	fr	Les horaires m'importent peu.
life_energie_rech	2	fr	L'énergie au quotidien m'importe peu.
life_orga_rech	2	fr	Le niveau d'organisation m'importe peu.
life_objets_rech	2	fr	Le rapport aux affaires m'importe peu.
life_cuisine_rech	3	fr	La cuisine m'importe peu.
life_proprete_rech	3	fr	La propreté m'importe peu.
life_manuel_rech	3	fr	Les talents manuels m'importent peu.
life_job_rech	3	fr	Le rythme de travail m'importe peu.
loisir_num_rech	4	fr	J'aimerais tout partager.
loisir_cult_rech	3	fr	Les sorties culturelles m'importent peu.
loisir_amis_rech	4	fr	Les sorties entre amis m'importent peu.
loisir_arts_rech	4	fr	Les pratiques artistiques m'importent peu.
loisir_passion_rech	4	fr	Ces passions m'importent peu.
loisir_benev_rech	1	fr	L'engagement associatif m'est égal.
voyage_aime_rech	2	fr	Le rapport au voyage m'importe peu.
voyage_style_rech	5	fr	Le style de voyage m'importe peu.
voyage_prepa_moi	3	fr	Je ne me soucie pas de mes affaires en voyage.
voyage_prepa_rech	2	fr	La préparation des voyages m'importe peu.
voyage_paysage_rech	4	fr	Tous les paysages me vont.
voyage_transp_rech	3	fr	Le mode de transport m'importe peu.
voyage_expat_rech	2	fr	L'expatriation m'importe peu pour l'instant.
sport_solo_rech	5	fr	Le sport individuel m'importe peu.
sport_groupe_rech	4	fr	Le sport collectif m'importe peu.
sport_freq_rech	4	fr	Le niveau de sport m'importe peu.
soc_extra_rech	3	fr	L'extraversion m'importe peu.
soc_intro_rech	3	fr	L'introversion m'importe peu.
soc_reseau_rech	2	fr	Le réseau professionnel m'importe peu.
soc_famille_rech	2	fr	Le lien familial m'importe peu.
soc_amis_rech	2	fr	La place des amis m'importe peu.
fin_vision_rech	3	fr	La vision financière m'importe peu.
mob_transp_rech	2	fr	Le mode de déplacement m'importe peu.
animaux_rech	3	fr	Les animaux m'importent peu.
com_integ_rech	3	fr	La façon de s'intégrer m'importe peu.
com_ecoute_moi	1	fr	En discussion, l'équilibre m'est égal.
com_emot_rech	3	fr	L'expression des émotions m'importe peu.
com_empathie_rech	2	fr	L'empathie de l'autre m'importe peu.
psy_confianc_rech	2	fr	La confiance en soi de l'autre m'importe peu.
psy_creativ_rech	2	fr	L'esprit artistique m'importe peu.
psy_ambition_rech	1	fr	L'ambition chez l'autre m'est égale.
psy_adaptab_rech	1	fr	L'adaptabilité de mon partenaire n'est pas un critère clé.
val_but_rech	3	fr	C'est son choix, cela m'importe peu.
val_spirit_rech	2	fr	La spiritualité de l'autre m'importe peu.
val_ecolo_rech	2	fr	L'écologie chez l'autre m'importe peu.
val_tradition_rech	2	fr	Le rapport aux traditions m'importe peu.
val_culture_rech	2	fr	Le niveau de culture m'importe peu.
db_enfants_rech	3	fr	Le projet d'enfants m'importe peu.
proj_statut_rech	2	fr	Le statut professionnel m'importe peu.
db_sex_or_rech	5	fr	L'orientation sexuelle m'importe peu.
phys_poids_rech	10	fr	Le poids m'importe peu.
mob_transp_moi	3	fr	Le mode de déplacement m'est égal.
mob_transp_rech	0	fr	Mon partenaire doit être véhiculé.
val_morale_moi	1	fr	La justice est une de mes valeurs fortes.
val_morale_moi	2	fr	Le respect est une de mes valeurs fortes.
vice_conso_moi	3	fr	Je ne fume jamais.
val_etudes_rech	0	fr	Je recherche au moins le baccalauréat.
val_etudes_rech	1	fr	Le diplôme ne compte pas pour moi.
fin_comport_rech	3	fr	Mon partenaire gère ses finances comme il ou elle le souhaite.
com_integ_rech	1	fr	J'aime que l'autre soit discret et ne monopolise pas la parole.
com_integ_rech	2	fr	J'aime que l'autre soit à l'écoute.
com_canal_rech	1	fr	J'attends quelqu'un qui aime les appels.
com_conflit_rech	2	fr	Lors d'une dispute, l'autre doit attendre que je revienne vers lui ou elle.
psy_creativ_rech	1	fr	Je ne recherche pas quelqu'un de créatif.
psy_respons_rech	0	fr	Mon partenaire idéal doit être très responsable.
psy_respons_rech	1	fr	Mon partenaire idéal peut garder un esprit enfantin.
\.


--
-- Data for Name: criterion_pairs; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.criterion_pairs (pair_key, slot, self_key, pref_key, category, cluster, grp, match_type, is_absolute, base_weight, mapping_validated, filtre_cadrage, affichable_apprentissage) FROM stdin;
phys_silhouette	3	phys_silhouette_moi	phys_silhouette_rech	PHYSIQUE	🟠 CLUSTER 5 - Hygiène de Vie & Physique	physique	aligne	f	1.00	t	f	t
phys_poitrine	4	phys_poitrine_moi	phys_poitrine_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Morphologie	physique	aligne	f	1.00	t	f	t
vis_forme	5	vis_forme_moi	vis_forme_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
genre	0	genre_moi	genre_rech	PHYSIQUE	🔴 FILTRE ABSOLU	physique	aligne	t	1.00	t	t	t
vis_machoire	7	vis_machoire_moi	vis_machoire_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
vis_menton	8	vis_menton_moi	vis_menton_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
vis_pommettes	9	vis_pommettes_moi	vis_pommettes_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
vis_front	10	vis_front_moi	vis_front_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
vis_nez	11	vis_nez_moi	vis_nez_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
vis_levres	12	vis_levres_moi	vis_levres_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
vis_dents_align	14	vis_dents_align_moi	vis_dents_align_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
vis_dents_blanches	15	vis_dents_blanches_m	vis_dents_blanches_r	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
vis_fossettes	16	vis_fossettes_moi	vis_fossettes_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
vis_traits	17	vis_traits_moi	vis_traits_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
yeux_couleur	18	yeux_couleur_moi	yeux_couleur_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	aligne	f	1.00	t	f	t
yeux_forme	19	yeux_forme_moi	yeux_forme_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
yeux_cils	20	yeux_cils_moi	yeux_cils_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
yeux_lunettes	21	yeux_lunettes_moi	yeux_lunettes_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
chev_longueur	22	chev_longueur_moi	chev_longueur_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
chev_couleur	23	chev_couleur_moi	chev_couleur_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
chev_forme	24	chev_forme_moi	chev_forme_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
chev_volume	25	chev_volume_moi	chev_volume_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
pil_barbe	26	pil_barbe_moi	pil_barbe_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
pil_corps	28	pil_corps_moi	pil_corps_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
pil_sourcils	29	pil_sourcils_moi	pil_sourcils_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
peau_couleur	30	peau_couleur_moi	peau_couleur_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Peau	physique	aligne	f	1.00	t	f	t
peau_bronzage	31	peau_bronzage_moi	peau_bronzage_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Peau	physique	aligne	f	1.00	t	f	t
peau_rousseur	32	peau_rousseur_moi	peau_rousseur_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Peau	physique	aligne	f	1.00	t	f	t
peau_grains_beaute	33	peau_grains_beaute_m	peau_grains_beaute_r	PHYSIQUE	⚪ ESTHÉTIQUE - Peau	physique	aligne	f	1.00	t	f	t
style_vetement	37	style_vetement_moi	style_vetement_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
style_piercings	39	style_piercings_moi	style_piercings_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
style_maquillage	40	style_maquillage_moi	style_maquillage_rec	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
style_parfum	41	style_parfum_moi	style_parfum_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	aligne	f	1.00	t	f	t
life_sommeil	42	life_sommeil_moi	life_sommeil_rech	MODE VIE	🟢 CLUSTER 1 - Rythme & Énergie	mode_vie	aligne	f	1.00	t	f	t
life_energie	44	life_energie_moi	life_energie_rech	MODE VIE	🟢 CLUSTER 1 - Rythme & Énergie	mode_vie	aligne	f	1.00	t	f	t
life_objets	46	life_objets_moi	life_objets_rech	MODE VIE	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	mode_vie	aligne	f	1.00	t	f	t
mob_transp	75	mob_transp_moi	mob_transp_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	mapping	f	1.00	t	f	t
animaux	76	animaux_moi	animaux_rech	MODE VIE	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	mode_vie	mapping	f	1.00	t	f	t
voyage_paysage	61	voyage_paysage_moi	voyage_paysage_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	aligne	f	1.00	t	f	t
vice_conso	77	vice_conso_moi	vice_conso_rech	MODE VIE	🟠 CLUSTER 5 - Hygiène de Vie & Physique	mode_vie	mapping	f	1.00	t	f	t
psy_vision	91	psy_vision_moi	psy_vision_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_rigueur	94	psy_rigueur_moi	psy_rigueur_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
val_religion	109	val_religion_moi	val_religion_rech	VALEURS	🔴 FILTRE ABSOLU	valeurs	echelle	t	1.00	t	f	f
val_politique	111	val_politique_moi	val_politique_rech	VALEURS	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	valeurs	mapping	f	1.00	t	f	f
soc_reseau	70	soc_reseau_moi	soc_reseau_rech	MODE VIE	🟢 CLUSTER 1 - Rythme & Énergie	mode_vie	aligne	f	1.00	t	f	t
val_etudes	115	val_etudes_moi	val_etudes_rech	VALEURS	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	valeurs	mapping	f	1.00	t	f	f
com_patienc	88	com_patienc_moi	com_patienc_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	aligne	f	1.00	t	f	t
val_morale	116	val_morale_moi	val_morale_rech	VALEURS	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	valeurs	mapping	f	1.00	t	f	t
db_relation	117	db_relation_moi	db_relation_rech	COUPLE	🔴 FILTRE ABSOLU	valeurs	mapping	t	1.00	t	f	t
db_regime	131	db_regime_moi	db_regime_rech	COUPLE	🔴 FILTRE ABSOLU	valeurs	mapping	t	1.00	t	f	t
db_sex_or	132	db_sex_or_moi	db_sex_or_rech	COUPLE	🔴 FILTRE ABSOLU	valeurs	aligne	t	1.00	t	t	t
phys_taille	1	phys_taille_moi	phys_taille_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Morphologie	physique	mapping	f	1.00	t	f	f
phys_poids	2	phys_poids_moi	phys_poids_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Morphologie	physique	mapping	f	1.00	t	f	f
vis_symetrie	6	vis_symetrie_moi	vis_symetrie_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	mapping	f	1.00	t	f	t
vis_sourire	13	vis_sourire_moi	vis_sourire_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Visage	physique	mapping	f	1.00	t	f	t
pil_moustache	27	pil_moustache_moi	pil_moustache_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	mapping	f	1.00	t	f	t
peau_cicatrices	34	peau_cicatrices_moi	peau_cicatrices_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Peau	physique	repoussoir	f	1.00	t	f	t
peau_acne	35	peau_acne_moi	peau_acne_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Peau	physique	mapping	f	1.00	t	f	t
peau_rides	36	peau_rides_moi	peau_rides_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Peau	physique	repoussoir	f	1.00	t	f	t
style_tatouages	38	style_tatouages_moi	style_tatouages_rech	PHYSIQUE	⚪ ESTHÉTIQUE - Style & Attributs	physique	mapping	f	1.00	t	f	t
life_horaires	43	life_horaires_moi	life_horaires_rech	MODE VIE	🟢 CLUSTER 1 - Rythme & Énergie	mode_vie	mapping	f	1.00	t	f	t
life_orga	45	life_orga_moi	life_orga_rech	MODE VIE	🟢 CLUSTER 1 - Rythme & Énergie	mode_vie	mapping	f	1.00	t	f	t
life_cuisine	47	life_cuisine_moi	life_cuisine_rech	MODE VIE	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	mode_vie	mapping	f	1.00	t	f	t
life_proprete	48	life_proprete_moi	life_proprete_rech	MODE VIE	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	mode_vie	mapping	f	1.00	t	f	t
life_manuel	49	life_manuel_moi	life_manuel_rech	MODE VIE	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	mode_vie	mapping	f	1.00	t	f	t
life_ecrans	50	life_ecrans_moi	life_ecrans_rech	MODE VIE	🟢 CLUSTER 1 - Rythme & Énergie	mode_vie	repoussoir	f	1.00	t	f	t
life_job	51	life_job_moi	life_job_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	mapping	f	1.00	t	f	t
loisir_num	52	loisir_num_moi	loisir_num_rech	MODE VIE	⚪ LOISIRS - Passions & Culture	mode_vie	mapping	f	1.00	t	f	t
loisir_cult	53	loisir_cult_moi	loisir_cult_rech	MODE VIE	⚪ LOISIRS - Passions & Culture	mode_vie	mapping	f	1.00	t	f	t
loisir_amis	54	loisir_amis_moi	loisir_amis_rech	MODE VIE	⚪ LOISIRS - Passions & Culture	mode_vie	mapping	f	1.00	t	f	t
loisir_arts	55	loisir_arts_moi	loisir_arts_rech	MODE VIE	⚪ LOISIRS - Passions & Culture	mode_vie	mapping	f	1.00	t	f	t
loisir_passion	56	loisir_passion_moi	loisir_passion_rech	MODE VIE	⚪ LOISIRS - Passions & Culture	mode_vie	mapping	f	1.00	t	f	t
loisir_benev	57	loisir_benev_moi	loisir_benev_rech	MODE VIE	⚪ LOISIRS - Passions & Culture	mode_vie	mapping	f	1.00	t	f	t
voyage_aime	58	voyage_aime_moi	voyage_aime_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	mapping	f	1.00	t	f	t
voyage_style	59	voyage_style_moi	voyage_style_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	mapping	f	1.00	t	f	t
voyage_prepa	60	voyage_prepa_moi	voyage_prepa_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	mapping	f	1.00	t	f	t
voyage_transp	62	voyage_transp_moi	voyage_transp_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	mapping	f	1.00	t	f	t
voyage_expat	63	voyage_expat_moi	voyage_expat_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	mapping	f	1.00	t	f	t
sport_solo	64	sport_solo_moi	sport_solo_rech	MODE VIE	🟠 CLUSTER 5 - Hygiène de Vie & Physique	mode_vie	mapping	f	1.00	t	f	t
sport_groupe	65	sport_groupe_moi	sport_groupe_rech	MODE VIE	🟠 CLUSTER 5 - Hygiène de Vie & Physique	mode_vie	mapping	f	1.00	t	f	t
sport_eau	66	sport_eau_moi	sport_eau_rech	MODE VIE	🟠 CLUSTER 5 - Hygiène de Vie & Physique	mode_vie	mapping	f	1.00	t	f	t
sport_freq	67	sport_freq_moi	sport_freq_rech	MODE VIE	🟠 CLUSTER 5 - Hygiène de Vie & Physique	mode_vie	mapping	f	1.00	t	f	t
soc_extra	68	soc_extra_moi	soc_extra_rech	MODE VIE	🟢 CLUSTER 1 - Rythme & Énergie	mode_vie	mapping	f	1.00	t	f	t
soc_intro	69	soc_intro_moi	soc_intro_rech	MODE VIE	🟢 CLUSTER 1 - Rythme & Énergie	mode_vie	mapping	f	1.00	t	f	t
soc_famille	71	soc_famille_moi	soc_famille_rech	MODE VIE	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	mode_vie	mapping	f	1.00	t	f	t
soc_amis	72	soc_amis_moi	soc_amis_rech	MODE VIE	🟢 CLUSTER 1 - Rythme & Énergie	mode_vie	mapping	f	1.00	t	f	t
fin_comport	73	fin_comport_moi	fin_comport_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	repoussoir	f	1.00	t	f	t
fin_vision	74	fin_vision_moi	fin_vision_rech	MODE VIE	🔵 CLUSTER 2 - Stabilité vs Aventure	mode_vie	mapping	f	1.00	t	f	t
com_integ	78	com_integ_moi	com_integ_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
com_drague	79	com_drague_moi	com_drague_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
com_ecoute	80	com_ecoute_moi	com_ecoute_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
com_emot	81	com_emot_moi	com_emot_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
db_mariage	118	db_mariage_moi	db_mariage_rech	COUPLE	🔴 FILTRE ABSOLU	valeurs	mapping	t	1.00	t	f	t
com_humour	82	com_humour_moi	com_humour_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
com_canal	83	com_canal_moi	com_canal_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
com_conflit	84	com_conflit_moi	com_conflit_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
com_franchis	85	com_franchis_moi	com_franchis_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
com_critiq	86	com_critiq_moi	com_critiq_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	repoussoir	f	1.00	t	f	t
com_empathie	87	com_empathie_moi	com_empathie_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_confianc	89	psy_confianc_moi	psy_confianc_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_anxiete	90	psy_anxiete_moi	psy_anxiete_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_curiosit	92	psy_curiosit_moi	psy_curiosit_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_creativ	93	psy_creativ_moi	psy_creativ_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_competit	95	psy_competit_moi	psy_competit_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_action	96	psy_action_moi	psy_action_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_risque	97	psy_risque_moi	psy_risque_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_ambition	98	psy_ambition_moi	psy_ambition_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_humilite	99	psy_humilite_moi	psy_humilite_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_control	100	psy_control_moi	psy_control_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_adaptab	101	psy_adaptab_moi	psy_adaptab_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_spontan	102	psy_spontan_moi	psy_spontan_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_discipli	103	psy_discipli_moi	psy_discipli_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_persever	104	psy_persever_moi	psy_persever_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
psy_respons	105	psy_respons_moi	psy_respons_rech	VALEURS	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
val_but	106	val_but_moi	val_but_rech	VALEURS	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	valeurs	mapping	f	1.00	t	f	t
val_fidelite	107	val_fidelite_moi	val_fidelite_rech	VALEURS	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	valeurs	mapping	f	1.00	t	f	t
val_honnete	108	val_honnete_moi	val_honnete_rech	VALEURS	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	valeurs	mapping	f	1.00	t	f	t
val_ecolo	112	val_ecolo_moi	val_ecolo_rech	VALEURS	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	valeurs	mapping	f	1.00	t	f	t
val_tradition	113	val_tradition_moi	val_tradition_rech	VALEURS	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	valeurs	mapping	f	1.00	t	f	t
val_culture	114	val_culture_moi	val_culture_rech	VALEURS	⚪ LOISIRS - Passions & Culture	valeurs	mapping	f	1.00	t	f	t
db_enfants	119	db_enfants_moi	db_enfants_rech	COUPLE	🔴 FILTRE ABSOLU	valeurs	mapping	t	1.00	t	f	t
cpl_dynamiq	120	cpl_dynamiq_moi	cpl_dynamiq_rech	COUPLE	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
cpl_fusion	121	cpl_fusion_moi	cpl_fusion_rech	COUPLE	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
cpl_affect	122	cpl_affect_moi	cpl_affect_rech	COUPLE	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
cpl_espace	123	cpl_espace_moi	cpl_espace_rech	COUPLE	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
cpl_jalous	124	cpl_jalous_moi	cpl_jalous_rech	COUPLE	🟣 CLUSTER 4 - Psycho, Com & Conflits	valeurs	mapping	f	1.00	t	f	t
proj_prio	125	proj_prio_moi	proj_prio_rech	PROJETS	🔵 CLUSTER 2 - Stabilité vs Aventure	valeurs	mapping	f	1.00	t	f	t
proj_statut	126	proj_statut_moi	proj_statut_rech	PROJETS	🔵 CLUSTER 2 - Stabilité vs Aventure	valeurs	mapping	f	1.00	t	f	t
proj_lieu	127	proj_lieu_moi	proj_lieu_rech	PROJETS	🔵 CLUSTER 2 - Stabilité vs Aventure	valeurs	mapping	f	1.00	t	f	t
proj_ancrage	128	proj_ancrage_moi	proj_ancrage_rech	PROJETS	🔵 CLUSTER 2 - Stabilité vs Aventure	valeurs	mapping	f	1.00	t	f	t
proj_retraite	129	proj_retraite_moi	proj_retraite_rech	PROJETS	🔵 CLUSTER 2 - Stabilité vs Aventure	valeurs	mapping	f	1.00	t	f	t
proj_rythme	130	proj_rythme_moi	proj_rythme_rech	PROJETS	🔵 CLUSTER 2 - Stabilité vs Aventure	valeurs	mapping	f	1.00	t	f	t
val_spirit	110	val_spirit_moi	val_spirit_rech	VALEURS	🟡 CLUSTER 3 - Bâtisseur de Foyer & Valeurs	valeurs	mapping	f	1.00	t	f	f
\.


--
-- Data for Name: partners; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partners (id, owner_id, langue, pays, nom_commercial, raison_sociale, adresse, code_postal, ville, telephone, email, site_web, google_place_id, google_maps_url, google_note, google_avis, google_verifie_le, status, motif_rejet, created_at, activated_at, location, commission_taux) FROM stdin;
\.


--
-- Data for Name: dates; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.dates (id, user_a, user_b, partner_id, creneau_debut, status, created_at, conversation_id, mode_rdv_active_at, ended_at, closed_at, ended_by, table_number) FROM stdin;
\.


--
-- Data for Name: date_followups; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.date_followups (date_id, user_id, decision, decided_at) FROM stdin;
\.


--
-- Data for Name: date_meeting_points; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.date_meeting_points (date_id, user_id, point, arrivee_at, expires_at, revealed_at) FROM stdin;
\.


--
-- Data for Name: date_presence; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.date_presence (date_id, user_id, arrived_at, confirmed_at, left_at, distance_m) FROM stdin;
\.


--
-- Data for Name: date_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.date_reviews (date_id, user_id, attirance, valeurs, mode_vie, commentaire, created_at) FROM stdin;
\.


--
-- Data for Name: deletion_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deletion_requests (user_id, requested_at, execute_after, executed_at, cancelled_at) FROM stdin;
\.


--
-- Data for Name: engine_params; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.engine_params (key, value, description, updated_at) FROM stdin;
poids_physique	0.25	Part du sous-score physique dans le score global	2026-07-31 00:57:31.693925+00
poids_valeurs	0.40	Part du sous-score valeurs dans le score global	2026-07-31 00:57:31.693925+00
poids_mode_vie	0.35	Part du sous-score mode de vie dans le score global	2026-07-31 00:57:31.693925+00
seuil_premium	85.0	Seuil de floutage des profils reserves aux abonnes	2026-07-31 00:57:31.693925+00
coef_rejet_fort	3.0	Poids d'un rejet depuis l'onglet Compatibles	2026-07-31 00:57:31.693925+00
coef_feedback_date	5.0	Poids du feedback post-rendez-vous	2026-07-31 00:57:31.693925+00
seuil_declassement	20.0	Nombre de decisions contredisant une preference avant declassement	2026-07-31 00:57:31.693925+00
partenaire_note_min	3.8	Note Google minimale d'un etablissement partenaire	2026-07-31 01:13:43.385609+00
partenaire_avis_min	35	Nombre minimal d'avis Google d'un etablissement partenaire	2026-07-31 01:13:43.385609+00
connaissance_part_paires	0.60	Part des paires completes dans le niveau de connaissance	2026-07-31 01:16:33.237672+00
connaissance_part_entropie	0.25	Part de la couverture ponderee par l'entropie	2026-07-31 01:16:33.237672+00
connaissance_part_interactions	0.15	Part des signaux comportementaux	2026-07-31 01:16:33.237672+00
connaissance_swipes_cible	200	Nombre de decisions de swipe pour saturer la part comportementale	2026-07-31 01:16:33.237672+00
priorites_visibles_gratuit	3	Priorites consultables sans abonnement	2026-07-31 01:16:33.237672+00
priorites_visibles_premium	20	Priorites consultables et reorganisables en premium	2026-07-31 01:16:33.237672+00
priorite_coef_max	3.0	Multiplicateur de poids de la priorite de rang 1	2026-07-31 01:16:33.237672+00
point_rdv_dist_min	60	Distance minimale entre un point de rendez-vous et l'etablissement, en metres	2026-07-31 01:18:22.978531+00
point_rdv_dist_max	100	Distance maximale entre un point de rendez-vous et l'etablissement, en metres	2026-07-31 01:18:22.978531+00
point_rdv_ecart_min	100	Distance minimale entre les deux points de rendez-vous, en metres	2026-07-31 01:18:22.978531+00
point_rdv_tentatives	400	Nombre de candidats tires avant echec declare	2026-07-31 01:18:22.978531+00
arrivee_tolerance_min	10	Tolerance d'arrivee en minutes	2026-07-31 01:18:22.978531+00
revelation_rayon_m	25	Rayon dans lequel l'utilisateur est repute arrive a son point	2026-07-31 01:18:22.978531+00
min_criteres_affiches	15	Nombre minimal de criteres evalues pour afficher un taux	2026-08-01 16:49:18.539988+00
plancher_directionnel	25	Score directionnel minimal	2026-08-01 16:49:40.476781+00
mutuel_poids_min	0.65	Part du score directionnel le plus faible dans le taux de compatibilite mutuelle	2026-08-05 19:40:01.995395+00
distance_evaluation_m	350	Eloignement minimal entre les deux utilisateurs avant d'afficher les evaluations	2026-08-05 19:40:01.995395+00
conversation_duree_s	300	Duree de la conversation chronometree, en secondes	2026-08-05 19:40:01.995395+00
demande_expiration_s	1800	Delai de reponse a une demande de discussion, en secondes	2026-08-05 19:40:01.995395+00
discussions_gratuit_par_jour	3	Nouvelles discussions quotidiennes en version gratuite	2026-08-05 19:40:01.995395+00
refus_reproposition_jours	60	Delai avant qu'un profil refuse puisse etre repropose	2026-08-05 19:43:11.434157+00
rayon_mobilite_partagee	1	Si 1, la distance acceptable est la somme des rayons des deux utilisateurs (mobilite simultanee)	2026-08-05 19:43:11.434157+00
apprentissage_accept_match	0.25	Poids d'une acceptation sur un critere satisfait (confirmation faible)	2026-08-05 19:49:47.419256+00
apprentissage_accept_nomatch	1.00	Poids d'une acceptation malgre un critere non satisfait (contradiction forte)	2026-08-05 19:49:47.419256+00
apprentissage_refus_nomatch	1.00	Poids d'un refus sur un critere non satisfait (confirmation forte)	2026-08-05 19:49:47.419256+00
apprentissage_refus_match	0.10	Poids d'un refus malgre un critere satisfait (signal tres faible)	2026-08-05 19:49:47.419256+00
apprentissage_mul_min	0.25	Multiplicateur appris minimal	2026-08-05 19:49:47.419256+00
apprentissage_mul_max	1.75	Multiplicateur appris maximal	2026-08-05 19:49:47.419256+00
apprentissage_amplitude	0.75	Amplitude de l'ajustement atteinte a seuil_declassement contradictions nettes	2026-08-05 19:49:47.419256+00
coef_conversation	2.00	Poids d'une decision prise a l'issue d'une conversation	2026-08-05 19:49:47.419256+00
apprentissage_seuil_refresh	0.02	Variation minimale d'un poids appris declenchant la reconstruction des vecteurs	2026-08-05 20:01:20.416092+00
apprentissage_fiabilite_min	0.15	Plancher de fiabilite : meme un comportement totalement uniforme continue d'apprendre, six fois plus lentement	2026-08-05 20:05:32.747234+00
apprentissage_derive_alerte	0.60	Part de criteres au plancher au-dela de laquelle un profil est signale comme derivant	2026-08-05 20:05:32.747234+00
commission_taux_defaut	0.15	Commission Safe Date appliquee a defaut de taux contractuel propre a l'etablissement	2026-08-05 20:33:34.017506+00
tva_taux_defaut	0.10	Taux de TVA applique par defaut sur la restauration	2026-08-05 20:33:34.017506+00
moderation_delai_rappel_h	4	Delai avant envoi du rappel des regles apres un signalement, en heures	2026-08-05 21:08:49.250425+00
moderation_suspension_jours	7	Duree d'une suspension temporaire, en jours	2026-08-05 21:08:49.250425+00
moderation_seuil_avertissement	2	Signalements traites avant de passer a l'avertissement	2026-08-05 21:08:49.250425+00
moderation_seuil_suspension	3	Mesures anterieures avant de passer a la suspension	2026-08-05 21:08:49.250425+00
moderation_seuil_bannissement	5	Mesures anterieures avant de proposer le bannissement	2026-08-05 21:08:49.250425+00
demande_delai_reponse_min	30	Delai de reponse a une demande de conversation, en minutes. Demarre a la premiere ouverture par le destinataire, pas a l'envoi.	2026-08-08 18:06:37.201816+00
demande_peremption_h	24	Duree au-dela de laquelle une demande jamais ouverte expire d'elle-meme, en heures.	2026-08-08 18:06:37.201816+00
demande_sursis_report_h	2	Sursis accorde par un report (plus tard), en heures. Utilisable une seule fois par demande.	2026-08-08 18:06:37.201816+00
demande_cooldown_relance_h	24	Delai minimal avant de pouvoir readresser une demande a la meme personne, en heures.	2026-08-08 18:06:37.201816+00
demande_max_tentatives	3	Nombre maximal de demandes vers une meme personne sur la fenetre glissante.	2026-08-08 18:06:37.201816+00
demande_fenetre_tentatives_j	30	Largeur de la fenetre glissante de comptage des tentatives, en jours.	2026-08-08 18:06:37.201816+00
demande_exclusion_refus_mois	6	Duree de l'exclusion mutuelle posee par un refus, en mois.	2026-08-08 18:06:37.201816+00
demande_file_active_max	8	Nombre maximal de demandes actives simultanees dans la boite de reception d'un utilisateur.	2026-08-08 18:06:37.201816+00
fil_page_taille	20	Nombre de profils retournes par page du fil.	2026-08-08 18:19:01.276763+00
focus_seuil_croix	5	Nombre de refus consecutifs avant de poser une question d'affinage.	2026-08-08 18:34:15.082763+00
focus_fenetre_max	20	Nombre maximal de refus recents analyses pour trouver le point commun.	2026-08-08 18:34:15.082763+00
focus_cooldown_h	12	Delai minimal entre deux questions d'affinage, en heures.	2026-08-08 18:34:15.082763+00
poids_swipe_apprentissage	1.0	Poids d'un swipe realise dans Mieux me connaitre : simple signal d'interet general.	2026-08-10 10:50:37.100414+00
poids_swipe_rencontre	2.5	Poids d'un swipe realise dans Partir en date : l'utilisateur envisage reellement la personne, le signal est plus fort.	2026-08-10 10:50:37.100414+00
focus_seuil_oui	5	Longueur d'une serie de oui consecutifs pouvant declencher une question.	2026-08-10 10:50:37.100414+00
attention_duree_fiable_ms	8000	Duree totale de consultation a partir de laquelle la repartition d'attention est jugee pleinement fiable, en millisecondes.	2026-08-10 10:54:53.691062+00
attention_poids_retour	0.35	Bonus applique par consultation supplementaire d'une meme section. Revenir sur un ecran est un signal d'attention plus fort qu'y rester passivement.	2026-08-10 10:54:53.691062+00
appr_lissage_confiance	25	Nombre d'observations a partir duquel la confiance atteint la moitie de son maximum. Plus la valeur est haute, plus le systeme est prudent.	2026-08-10 10:58:56.808849+00
appr_min_obs_option	3	Observations minimales sur une option avant de la faire peser dans le calcul d'importance.	2026-08-10 10:58:56.808849+00
appr_fenetre_recente	200	Nombre de swipes les plus recents constituant la fenetre d'analyse de tendance.	2026-08-10 10:58:56.808849+00
appr_seuil_derive	0.20	Ecart entre taux global et taux recent au-dela duquel une evolution de preference est signalee.	2026-08-10 10:58:56.808849+00
appr_criteres_sensibles	0	Inclure les criteres sensibles (origine, religion, sante, orientation, genre, opinions) dans l'apprentissage comportemental. 0 = exclus. A ne passer a 1 qu'apres arbitrage juridique explicite.	2026-08-10 10:58:56.808849+00
expl_taux_initial	0.85	Part d'exploration chez un utilisateur dont on ne sait rien.	2026-08-10 11:09:29.613793+00
expl_taux_plancher	0.20	Part d'exploration conservee meme chez un utilisateur tres bien connu. Ne descend jamais a zero : sans exploration, le moteur cesse de verifier ses propres hypotheses.	2026-08-10 11:09:29.613793+00
expl_maturite_swipes	500	Nombre de swipes d'apprentissage au terme duquel la part d'exploration atteint son plancher.	2026-08-10 11:09:29.613793+00
expl_confiance_acquise	0.80	Confiance au-dela de laquelle un critere est considere comme suffisamment documente.	2026-08-10 11:09:29.613793+00
expl_proba_retest	0.05	Probabilite de reexposer un critere deja bien connu. Une preference forte peut evoluer : ne plus jamais la tester reviendrait a la figer.	2026-08-10 11:09:29.613793+00
expl_plancher_attendu	0.15	Acceptation attendue en dessous de laquelle un profil cesse d'etre propose a un utilisateur mature.	2026-08-10 11:09:29.613793+00
pond_lissage	40	Nombre de swipes contextualises a partir duquel les ponderations apprises pesent autant que les valeurs de reference.	2026-08-10 11:11:17.337258+00
pond_ecart_max	0.25	Ecart maximal autorise en une seule consolidation, pour eviter qu'une poignee de swipes ne bascule tout le modele.	2026-08-10 11:11:17.337258+00
focus_seuil_erreur	0.45	Ecart entre prediction et decision au-dela duquel un Focus devient pertinent.	2026-08-10 11:14:31.648471+00
focus_proba_serie	0.65	Probabilite qu'une serie homogene declenche effectivement une question. Inferieure a 1 pour que la regle reste indevinable.	2026-08-10 11:14:31.648471+00
focus_proba_erreur	0.80	Probabilite qu'une erreur de prediction marquee declenche une question. Plus haute : c'est la que le moteur a le plus a apprendre.	2026-08-10 11:14:31.648471+00
sig_niveau1_appr	1.0	Poids du signal : swipe dans Mieux me connaitre. Interet general.	2026-08-10 11:23:29.319093+00
sig_niveau2_date	2.5	Poids du signal : swipe dans Partir en date. Interet dans un contexte reel de recherche.	2026-08-10 11:23:29.319093+00
sig_niveau3_vecu	6.0	Poids du signal : retour apres le rendez-vous. Experience reellement vecue.	2026-08-10 11:23:29.319093+00
sig_niveau4_suite	8.0	Poids du signal : souhait de poursuivre apres la rencontre.	2026-08-10 11:23:29.319093+00
sig_niveau5_nouveau	10.0	Poids du signal : nouveau rendez-vous organise. Interet reel confirme par les actes.	2026-08-10 11:23:29.319093+00
exp_echelle_max	5.0	Valeur maximale de l'echelle des retours post-rendez-vous.	2026-08-10 11:23:29.319093+00
exp_lissage	8.0	Nombre de rencontres a partir duquel le pouvoir predictif d'un critere devient credible. Volontairement bas : une rencontre reelle vaut beaucoup de swipes.	2026-08-10 11:23:29.319093+00
presence_fraicheur_s	45	Duree pendant laquelle un signe de vie vaut presence, en secondes.	2026-08-10 11:38:55.611104+00
conversation_prete_peremption_h	48	Delai au-dela duquel une conversation prete mais jamais demarree est cloturee.	2026-08-10 11:38:55.611104+00
conversation_decompte_s	3	Duree du decompte affiche avant le demarrage effectif.	2026-08-10 11:38:55.611104+00
present_criteres_min	8	Nombre minimal de criteres affiches sur un profil en apprentissage.	2026-08-10 11:50:03.026217+00
present_criteres_max	12	Nombre maximal de criteres affiches sur un profil en apprentissage. Au-dela, la lecture cesse d'etre rapide et le profil devient un formulaire.	2026-08-10 11:50:03.026217+00
present_part_valeurs	0.5	Part visee de criteres issus des valeurs, le reste venant du mode de vie.	2026-08-10 11:50:03.026217+00
quest_cadence_min	8	Nombre minimal de profils entre deux questions intermediaires, quand le moteur connait mal l'utilisateur.	2026-08-10 11:55:23.208907+00
quest_cadence_max	30	Nombre maximal de profils entre deux questions, quand le profil est deja bien documente.	2026-08-10 11:55:23.208907+00
quest_proba	0.75	Probabilite qu'une question soit posee une fois la cadence atteinte. Une regularite parfaite donnerait l'impression d'un questionnaire.	2026-08-10 11:55:23.208907+00
session_duree_cible_min	7	Duree moyenne visee pour une session d'apprentissage, en minutes.	2026-08-10 11:59:17.331577+00
session_quota_gratuit	40	Nombre de profils consultables par jour en version gratuite. Zero signifie aucune limite.	2026-08-10 11:59:17.331577+00
contraste_taille	4	Nombre de profils composant une serie contrastive.	2026-08-10 12:01:51.364578+00
contraste_conf_max	0.70	Confiance au-dela de laquelle un critere ne merite plus d'etre isole.	2026-08-10 12:01:51.364578+00
contraste_proba	0.30	Probabilite qu'une page de fil soit consacree a une serie contrastive plutot qu'au classement habituel.	2026-08-10 12:01:51.364578+00
\.


--
-- Data for Name: fake_contacts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.fake_contacts (id, genre, prenom, photo_path, message_template, active) FROM stdin;
5548d6a1-3b27-4567-9d8d-ee3fd58b549a	homme	Julien	\N	Salut ! Désolé de te déranger mais j'ai vraiment besoin de toi. Est-ce que tu peux me rejoindre rapidement ? C'est urgent. Je t'ai envoyé ma position.	t
aa4a5439-1137-46bf-93f7-3c1f0178b61e	homme	Maxime	\N	Salut ! Désolé de te déranger mais j'ai vraiment besoin de toi. Est-ce que tu peux me rejoindre rapidement ? C'est urgent. Je t'ai envoyé ma position.	t
4410c967-8772-48b6-9006-91bb6bf99dfc	femme	Sarah	\N	Salut ! Désolée de te déranger mais j'ai vraiment besoin de toi. Est-ce que tu peux me rejoindre rapidement ? C'est urgent. Je t'ai envoyé ma position.	t
450df4f4-a3b5-4c16-8f9e-7d4f0f66c61d	femme	Camille	\N	Salut ! Désolée de te déranger mais j'ai vraiment besoin de toi. Est-ce que tu peux me rejoindre rapidement ? C'est urgent. Je t'ai envoyé ma position.	t
\.


--
-- Data for Name: profile_presentations; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profile_presentations (id, observer_id, target_id, contexte, ordre_pages, criteres, created_at, critere_isole, serie_id) FROM stdin;
\.


--
-- Data for Name: swipe_decisions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.swipe_decisions (id, user_id, target_id, decision, signal_fort, ecran, duree_ms, created_at, contexte, duree_totale_ms, ordre_consultation, retours, criteres_exposes, criteres_consultes, attention_physique, attention_mode_vie, attention_valeurs, fiabilite_attention, snapshot, type_rencontre, score_predit, seuil_predit, erreur_prediction, presentation_id, pages_ignorees, vitesse_ms_page) FROM stdin;
2	d0000000-0000-4000-8000-00000000000a	d0000000-0000-4000-8000-000000000002	f	f	decouverte	4033	2026-08-01 20:43:00.018035+00	partir_en_date	\N	\N	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
3	d0000000-0000-4000-8000-00000000000a	d0000000-0000-4000-8000-000000000003	t	f	decouverte	1304	2026-08-01 20:43:01.282974+00	partir_en_date	\N	\N	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
4	d0000000-0000-4000-8000-00000000000a	d0000000-0000-4000-8000-000000000001	t	f	decouverte	1161	2026-08-01 20:43:02.449028+00	partir_en_date	\N	\N	0	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N	\N
\.


--
-- Data for Name: focus_compatibilite; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.focus_compatibilite (id, user_id, context, target_user_id, target_partner_id, question, reponse, created_at, answered_at, criterion_key, sens, swipe_id, options) FROM stdin;
\.


--
-- Data for Name: grille_import_v1; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.grille_import_v1 (src_row, pair_key, pref_idx, pref_label, accepted, poids, commentaire) FROM stdin;
\.


--
-- Data for Name: help_requests; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_requests (id, date_id, user_id, level, fake_contact_id, partner_notified_at, created_at, resolved_at, analyse_terminee_at, mesure_prise) FROM stdin;
\.


--
-- Data for Name: help_staff_reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_staff_reports (id, help_request_id, partner_id, staff_identifiant, table_number, circonstances, faits, actions, depart_accompagne, secours_appeles, observations, dangerosite, submitted_at) FROM stdin;
\.


--
-- Data for Name: help_user_reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.help_user_reports (help_request_id, user_id, raison, recit, comportement, ressenti, complement, submitted_at) FROM stdin;
\.


--
-- Data for Name: user_photos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_photos (id, user_id, storage_path, "position", moderation, moderated_at, created_at, is_primary) FROM stdin;
\.


--
-- Data for Name: identity_verifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.identity_verifications (id, user_id, provider, provider_ref, status, liveness_ok, age_estimated, checked_at, created_at, comparison_ok, comparison_score, photo_id) FROM stdin;
\.


--
-- Data for Name: payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.payments (id, date_id, payer_id, partner_id, kind, mode, amount_cents, tip_cents, currency, stripe_payment_intent_id, status, created_at, captured_at) FROM stdin;
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoices (id, date_id, payment_id, partner_id, user_id, number, type, issued_at, paid_at, covers, subtotal_ht_cents, vat_cents, total_ttc_cents, tip_cents, billing_info, pdf_path) FROM stdin;
\.


--
-- Data for Name: invoice_lines; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.invoice_lines (id, invoice_id, label, quantity, unit_price_cents, vat_rate, total_cents) FROM stdin;
\.


--
-- Data for Name: menu_stopwords; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.menu_stopwords (mot) FROM stdin;
cafe
bar
restaurant
brasserie
bistrot
salon
the
pub
taverne
auberge
grill
table
maison
chez
les
des
une
sarl
sas
sasu
eurl
snc
gmbh
company
\.


--
-- Data for Name: messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.messages (id, conversation_id, sender_id, kind, body, audio_path, duration_ms, created_at) FROM stdin;
\.


--
-- Data for Name: reports; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.reports (id, reporter_id, reported_id, reason, details, status, created_at, handled_at, handled_by, outcome) FROM stdin;
\.


--
-- Data for Name: moderation_actions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.moderation_actions (id, user_id, report_id, action, motif, decided_by, decided_at, expires_at, leve_at) FROM stdin;
\.


--
-- Data for Name: option_mappings; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.option_mappings (pair_key, pref_idx, accepted_self_idx, weight_multiplier, tolerance, relative_op, relative_criterion_key, accepted_mask) FROM stdin;
val_religion	0	{0,1,2,3,4}	0.00	4	\N	\N	31
val_religion	1	{1}	1.00	3	\N	\N	2
val_religion	2	{2}	1.00	2	\N	\N	4
val_religion	3	{3}	1.00	1	\N	\N	8
val_religion	4	{4}	2.00	0	\N	\N	16
genre	0	{0}	1.00	\N	\N	\N	1
genre	1	{1}	1.00	\N	\N	\N	2
genre	2	{2}	1.00	\N	\N	\N	4
genre	3	{0,1,2}	0.00	\N	\N	\N	7
phys_silhouette	0	{0}	1.00	\N	\N	\N	1
phys_silhouette	1	{1}	1.00	\N	\N	\N	2
phys_silhouette	2	{2}	1.00	\N	\N	\N	4
phys_silhouette	3	{3}	1.00	\N	\N	\N	8
phys_silhouette	4	{0,1,2,3}	0.00	\N	\N	\N	15
phys_poitrine	0	{0}	1.00	\N	\N	\N	1
phys_poitrine	1	{1}	1.00	\N	\N	\N	2
phys_poitrine	2	{2}	1.00	\N	\N	\N	4
phys_poitrine	3	{3}	1.00	\N	\N	\N	8
phys_poitrine	4	{0,1,2,3}	0.00	\N	\N	\N	15
vis_forme	0	{0}	1.00	\N	\N	\N	1
vis_forme	1	{1}	1.00	\N	\N	\N	2
vis_forme	2	{2}	1.00	\N	\N	\N	4
vis_forme	3	{0,1,2}	0.00	\N	\N	\N	7
vis_machoire	0	{0}	1.00	\N	\N	\N	1
chev_volume	2	{0,1}	0.00	\N	\N	\N	3
pil_barbe	0	{0}	1.00	\N	\N	\N	1
pil_barbe	1	{1}	1.00	\N	\N	\N	2
pil_barbe	2	{2}	1.00	\N	\N	\N	4
pil_barbe	3	{3}	1.00	\N	\N	\N	8
pil_barbe	4	{0,1,2,3}	0.00	\N	\N	\N	15
pil_corps	0	{0}	1.00	\N	\N	\N	1
pil_corps	1	{1}	1.00	\N	\N	\N	2
pil_corps	2	{2}	1.00	\N	\N	\N	4
pil_corps	3	{0,1,2}	0.00	\N	\N	\N	7
pil_sourcils	0	{0}	1.00	\N	\N	\N	1
pil_sourcils	1	{1}	1.00	\N	\N	\N	2
pil_sourcils	2	{2}	1.00	\N	\N	\N	4
pil_sourcils	3	{0,1,2}	0.00	\N	\N	\N	7
vis_machoire	1	{1}	1.00	\N	\N	\N	2
vis_machoire	2	{0,1}	0.00	\N	\N	\N	3
vis_menton	0	{0}	1.00	\N	\N	\N	1
vis_menton	1	{1}	1.00	\N	\N	\N	2
vis_menton	2	{0,1}	0.00	\N	\N	\N	3
vis_pommettes	0	{0}	1.00	\N	\N	\N	1
vis_pommettes	1	{1}	1.00	\N	\N	\N	2
vis_pommettes	2	{0,1}	0.00	\N	\N	\N	3
vis_front	0	{0}	1.00	\N	\N	\N	1
vis_front	1	{1}	1.00	\N	\N	\N	2
vis_front	2	{2}	1.00	\N	\N	\N	4
vis_front	3	{0,1,2}	0.00	\N	\N	\N	7
vis_nez	0	{0}	1.00	\N	\N	\N	1
vis_nez	1	{1}	1.00	\N	\N	\N	2
vis_nez	2	{2}	1.00	\N	\N	\N	4
vis_nez	3	{0,1,2}	0.00	\N	\N	\N	7
vis_levres	0	{0}	1.00	\N	\N	\N	1
vis_levres	1	{1}	1.00	\N	\N	\N	2
phys_taille	10	{}	1.00	\N	sup	\N	0
vis_levres	2	{2}	1.00	\N	\N	\N	4
vis_levres	3	{0,1,2}	0.00	\N	\N	\N	7
vis_dents_align	0	{0}	1.00	\N	\N	\N	1
vis_dents_align	1	{1}	1.00	\N	\N	\N	2
vis_dents_align	2	{0,1}	0.00	\N	\N	\N	3
vis_dents_blanches	0	{0}	1.00	\N	\N	\N	1
vis_dents_blanches	1	{1}	1.00	\N	\N	\N	2
vis_dents_blanches	2	{0,1}	0.00	\N	\N	\N	3
vis_fossettes	0	{0}	1.00	\N	\N	\N	1
vis_fossettes	1	{1}	1.00	\N	\N	\N	2
vis_fossettes	2	{0,1}	0.00	\N	\N	\N	3
vis_traits	0	{0}	1.00	\N	\N	\N	1
vis_traits	1	{1}	1.00	\N	\N	\N	2
vis_traits	2	{0,1}	0.00	\N	\N	\N	3
yeux_couleur	0	{0}	1.00	\N	\N	\N	1
yeux_couleur	1	{1}	1.00	\N	\N	\N	2
yeux_couleur	2	{2}	1.00	\N	\N	\N	4
yeux_couleur	3	{3}	1.00	\N	\N	\N	8
yeux_couleur	4	{4}	1.00	\N	\N	\N	16
yeux_couleur	5	{5}	1.00	\N	\N	\N	32
yeux_couleur	6	{0,1,2,3,4,5}	0.00	\N	\N	\N	63
yeux_forme	0	{0}	1.00	\N	\N	\N	1
yeux_forme	1	{1}	1.00	\N	\N	\N	2
yeux_forme	2	{2}	1.00	\N	\N	\N	4
yeux_forme	3	{0,1,2}	0.00	\N	\N	\N	7
yeux_cils	0	{0}	1.00	\N	\N	\N	1
yeux_cils	1	{1}	1.00	\N	\N	\N	2
yeux_cils	2	{0,1}	0.00	\N	\N	\N	3
yeux_lunettes	0	{0}	1.00	\N	\N	\N	1
yeux_lunettes	1	{1}	1.00	\N	\N	\N	2
yeux_lunettes	2	{0,1}	0.00	\N	\N	\N	3
chev_longueur	0	{0}	1.00	\N	\N	\N	1
chev_longueur	1	{1}	1.00	\N	\N	\N	2
chev_longueur	2	{2}	1.00	\N	\N	\N	4
chev_longueur	3	{3}	1.00	\N	\N	\N	8
chev_longueur	4	{4}	1.00	\N	\N	\N	16
chev_longueur	5	{0,1,2,3,4}	0.00	\N	\N	\N	31
chev_couleur	0	{0}	1.00	\N	\N	\N	1
chev_couleur	1	{1}	1.00	\N	\N	\N	2
chev_couleur	2	{2}	1.00	\N	\N	\N	4
chev_couleur	3	{3}	1.00	\N	\N	\N	8
chev_couleur	4	{4}	1.00	\N	\N	\N	16
chev_couleur	5	{5}	1.00	\N	\N	\N	32
chev_couleur	6	{0,1,2,3,4,5}	0.00	\N	\N	\N	63
chev_forme	0	{0}	1.00	\N	\N	\N	1
chev_forme	1	{1}	1.00	\N	\N	\N	2
chev_forme	2	{2}	1.00	\N	\N	\N	4
chev_forme	3	{3}	1.00	\N	\N	\N	8
chev_forme	4	{0,1,2,3}	0.00	\N	\N	\N	15
chev_volume	0	{0}	1.00	\N	\N	\N	1
chev_volume	1	{1}	1.00	\N	\N	\N	2
peau_couleur	0	{0}	1.00	\N	\N	\N	1
peau_couleur	1	{1}	1.00	\N	\N	\N	2
peau_couleur	2	{2}	1.00	\N	\N	\N	4
peau_couleur	3	{0,1,2}	0.00	\N	\N	\N	7
peau_bronzage	0	{0}	1.00	\N	\N	\N	1
peau_bronzage	1	{1}	1.00	\N	\N	\N	2
peau_bronzage	2	{0,1}	0.00	\N	\N	\N	3
peau_rousseur	0	{0}	1.00	\N	\N	\N	1
peau_rousseur	1	{1}	1.00	\N	\N	\N	2
peau_rousseur	2	{0,1}	0.00	\N	\N	\N	3
peau_grains_beaute	0	{0}	1.00	\N	\N	\N	1
peau_grains_beaute	1	{1}	1.00	\N	\N	\N	2
peau_grains_beaute	2	{0,1}	0.00	\N	\N	\N	3
style_vetement	0	{0}	1.00	\N	\N	\N	1
style_vetement	1	{1}	1.00	\N	\N	\N	2
style_vetement	2	{2}	1.00	\N	\N	\N	4
style_vetement	3	{3}	1.00	\N	\N	\N	8
style_vetement	4	{4}	1.00	\N	\N	\N	16
style_vetement	5	{5}	1.00	\N	\N	\N	32
style_vetement	6	{0,1,2,3,4,5}	0.00	\N	\N	\N	63
style_piercings	0	{0}	1.00	\N	\N	\N	1
style_piercings	1	{1}	1.00	\N	\N	\N	2
style_piercings	2	{0,1}	0.00	\N	\N	\N	3
style_maquillage	0	{0}	1.00	\N	\N	\N	1
style_maquillage	1	{1}	1.00	\N	\N	\N	2
style_maquillage	2	{2}	1.00	\N	\N	\N	4
style_maquillage	3	{3}	1.00	\N	\N	\N	8
style_maquillage	4	{0,1,2,3}	0.00	\N	\N	\N	15
style_parfum	0	{0}	1.00	\N	\N	\N	1
style_parfum	1	{1}	1.00	\N	\N	\N	2
style_parfum	2	{0,1}	0.00	\N	\N	\N	3
life_sommeil	0	{0}	1.00	\N	\N	\N	1
life_sommeil	1	{1}	1.00	\N	\N	\N	2
life_sommeil	2	{0,1}	0.00	\N	\N	\N	3
life_energie	0	{0}	1.00	\N	\N	\N	1
life_energie	1	{1}	1.00	\N	\N	\N	2
life_energie	2	{0,1}	0.00	\N	\N	\N	3
life_objets	0	{0}	1.00	\N	\N	\N	1
life_objets	1	{1}	1.00	\N	\N	\N	2
life_objets	2	{0,1}	0.00	\N	\N	\N	3
voyage_paysage	0	{0}	1.00	\N	\N	\N	1
voyage_paysage	1	{1}	1.00	\N	\N	\N	2
voyage_paysage	2	{2}	1.00	\N	\N	\N	4
voyage_paysage	3	{3}	1.00	\N	\N	\N	8
voyage_paysage	4	{0,1,2,3}	0.00	\N	\N	\N	15
soc_reseau	0	{0}	1.00	\N	\N	\N	1
soc_reseau	1	{1}	1.00	\N	\N	\N	2
soc_reseau	2	{0,1}	0.00	\N	\N	\N	3
com_patienc	0	{0}	1.00	\N	\N	\N	1
com_patienc	1	{1}	1.00	\N	\N	\N	2
db_sex_or	0	{0}	1.00	\N	\N	\N	1
db_sex_or	1	{1}	1.00	\N	\N	\N	2
db_sex_or	2	{2}	1.00	\N	\N	\N	4
db_sex_or	3	{3}	1.00	\N	\N	\N	8
db_sex_or	4	{4}	1.00	\N	\N	\N	16
db_sex_or	5	{0,1,2,3,4}	0.00	\N	\N	\N	31
phys_taille	0	{0}	1.00	\N	\N	\N	1
phys_taille	1	{1}	1.00	\N	\N	\N	2
phys_taille	2	{2}	1.00	\N	\N	\N	4
phys_taille	3	{3}	1.00	\N	\N	\N	8
phys_taille	4	{4}	1.00	\N	\N	\N	16
phys_taille	5	{5}	1.00	\N	\N	\N	32
phys_taille	6	{6}	1.00	\N	\N	\N	64
phys_taille	7	{7}	1.00	\N	\N	\N	128
phys_taille	8	{8}	1.00	\N	\N	\N	256
phys_taille	9	{9}	1.00	\N	\N	\N	512
phys_poids	0	{0}	1.00	\N	\N	\N	1
phys_poids	1	{1}	1.00	\N	\N	\N	2
phys_poids	2	{2}	1.00	\N	\N	\N	4
phys_poids	3	{3}	1.00	\N	\N	\N	8
phys_poids	4	{4}	1.00	\N	\N	\N	16
phys_poids	5	{5}	1.00	\N	\N	\N	32
phys_poids	6	{6}	1.00	\N	\N	\N	64
phys_poids	7	{7}	1.00	\N	\N	\N	128
phys_poids	8	{8}	1.00	\N	\N	\N	256
phys_poids	9	{9}	1.00	\N	\N	\N	512
vis_symetrie	0	{0}	2.00	\N	\N	\N	1
vis_symetrie	1	{0,1}	0.00	\N	\N	\N	3
vis_sourire	0	{0}	2.00	\N	\N	\N	1
vis_sourire	1	{1}	1.00	\N	\N	\N	2
vis_sourire	2	{0,1}	0.00	\N	\N	\N	3
pil_moustache	0	{0}	1.00	\N	\N	\N	1
pil_moustache	1	{1}	1.00	\N	\N	\N	2
pil_moustache	2	{2}	2.00	\N	\N	\N	4
pil_moustache	3	{0,1,2}	0.00	\N	\N	\N	7
peau_cicatrices	0	{1}	2.00	\N	\N	\N	2
peau_cicatrices	1	{0}	0.50	\N	\N	\N	1
peau_cicatrices	2	{0,1}	0.00	\N	\N	\N	3
peau_acne	0	{1}	2.00	\N	\N	\N	2
peau_acne	1	{0}	0.50	\N	\N	\N	1
peau_acne	2	{0,1}	0.00	\N	\N	\N	3
peau_rides	0	{1}	2.00	\N	\N	\N	2
peau_rides	1	{0}	0.50	\N	\N	\N	1
peau_rides	2	{0,1}	0.00	\N	\N	\N	3
style_tatouages	0	{0}	0.50	\N	\N	\N	1
style_tatouages	1	{1}	1.00	\N	\N	\N	2
style_tatouages	2	{0,1}	0.00	\N	\N	\N	3
life_horaires	0	{0}	1.00	\N	\N	\N	1
life_horaires	1	{0,1}	1.00	\N	\N	\N	3
life_horaires	2	{0,1}	0.00	\N	\N	\N	3
life_orga	0	{0}	2.00	\N	\N	\N	1
life_orga	1	{1}	1.00	\N	\N	\N	2
life_orga	2	{0,1}	0.00	\N	\N	\N	3
life_cuisine	0	{1}	1.00	\N	\N	\N	2
life_cuisine	1	{0,1}	1.00	\N	\N	\N	3
life_cuisine	2	{0,2}	1.00	\N	\N	\N	5
life_cuisine	3	{0,1,2}	0.00	\N	\N	\N	7
life_proprete	0	{0,1,2}	0.50	\N	\N	\N	7
life_proprete	1	{1,2,3}	1.00	\N	\N	\N	14
life_proprete	2	{2,3}	2.00	\N	\N	\N	12
life_proprete	3	{0,1,2,3}	0.00	\N	\N	\N	15
life_manuel	0	{0}	1.00	\N	\N	\N	1
life_manuel	1	{1}	1.00	\N	\N	\N	2
life_manuel	2	{2}	1.00	\N	\N	\N	4
life_manuel	3	{0,1,2,3}	0.00	\N	\N	\N	15
life_ecrans	0	{1,2}	2.00	\N	\N	\N	6
life_ecrans	1	{0,2}	1.00	\N	\N	\N	5
life_ecrans	2	{0,1,2}	0.00	\N	\N	\N	7
life_job	0	{0,1,3}	1.00	\N	\N	\N	11
life_job	1	{1}	1.00	\N	\N	\N	2
life_job	2	{1,2}	1.00	\N	\N	\N	6
life_job	3	{0,1,2,3}	0.00	\N	\N	\N	15
loisir_num	0	{0}	1.00	\N	\N	\N	1
loisir_num	1	{1}	1.00	\N	\N	\N	2
loisir_num	2	{2}	1.00	\N	\N	\N	4
loisir_num	3	{3}	1.00	\N	\N	\N	8
loisir_num	4	{0,1,2,3}	0.00	\N	\N	\N	15
loisir_cult	0	{0}	1.00	\N	\N	\N	1
loisir_cult	1	{1}	1.00	\N	\N	\N	2
loisir_cult	2	{2}	1.00	\N	\N	\N	4
loisir_cult	3	{0,1,2}	0.00	\N	\N	\N	7
loisir_amis	0	{0,1}	1.00	\N	\N	\N	3
loisir_amis	1	{2,3}	1.00	\N	\N	\N	12
loisir_amis	2	{2}	1.00	\N	\N	\N	4
loisir_amis	3	{3,4}	1.00	\N	\N	\N	24
loisir_amis	4	{0,1,2,3,4}	0.00	\N	\N	\N	31
loisir_arts	0	{0}	1.00	\N	\N	\N	1
loisir_arts	1	{1}	1.00	\N	\N	\N	2
loisir_arts	2	{2}	1.00	\N	\N	\N	4
loisir_arts	3	{3}	1.00	\N	\N	\N	8
loisir_arts	4	{0,1,2,3}	0.00	\N	\N	\N	15
loisir_passion	0	{0}	1.00	\N	\N	\N	1
loisir_passion	1	{1}	1.00	\N	\N	\N	2
loisir_passion	2	{2}	1.00	\N	\N	\N	4
loisir_passion	3	{3}	1.00	\N	\N	\N	8
loisir_passion	4	{0,1,2,3}	0.00	\N	\N	\N	15
loisir_benev	0	{0,2}	2.00	\N	\N	\N	5
loisir_benev	1	{0,1,2}	0.00	\N	\N	\N	7
voyage_aime	0	{0}	1.00	\N	\N	\N	1
voyage_aime	1	{1}	1.00	\N	\N	\N	2
voyage_aime	2	{0,1}	0.00	\N	\N	\N	3
voyage_style	0	{0}	1.00	\N	\N	\N	1
voyage_style	1	{1}	1.00	\N	\N	\N	2
voyage_style	2	{2}	1.00	\N	\N	\N	4
voyage_style	3	{3}	1.00	\N	\N	\N	8
voyage_style	4	{4}	1.00	\N	\N	\N	16
voyage_style	5	{0,1,2,3,4}	0.00	\N	\N	\N	31
voyage_prepa	0	{1,2}	1.00	\N	\N	\N	6
voyage_prepa	1	{0,3}	1.00	\N	\N	\N	9
voyage_prepa	2	{0,1,2,3}	0.00	\N	\N	\N	15
voyage_transp	0	{1}	1.00	\N	\N	\N	2
voyage_transp	1	{0,3,4,5}	1.00	\N	\N	\N	57
voyage_transp	2	{2}	1.00	\N	\N	\N	4
voyage_transp	3	{0,1,2,3,4,5}	0.00	\N	\N	\N	63
voyage_expat	0	{0}	2.00	\N	\N	\N	1
voyage_expat	1	{1}	2.00	\N	\N	\N	2
voyage_expat	2	{0,1}	0.00	\N	\N	\N	3
sport_solo	0	{0}	1.00	\N	\N	\N	1
sport_solo	1	{1}	1.00	\N	\N	\N	2
sport_solo	2	{2}	1.00	\N	\N	\N	4
sport_solo	3	{3}	1.00	\N	\N	\N	8
sport_solo	4	{4}	1.00	\N	\N	\N	16
sport_solo	5	{0,1,2,3,4}	0.00	\N	\N	\N	31
sport_groupe	0	{0,1}	1.00	\N	\N	\N	3
sport_groupe	1	{2}	1.00	\N	\N	\N	4
sport_groupe	2	{3}	1.00	\N	\N	\N	8
sport_groupe	3	{4}	1.00	\N	\N	\N	16
sport_groupe	4	{0,1,2,3,4}	0.00	\N	\N	\N	31
sport_eau	0	{0,1,2}	2.00	\N	\N	\N	7
sport_eau	1	{0,1,2,3}	0.00	\N	\N	\N	15
sport_freq	0	{0}	1.00	\N	\N	\N	1
sport_freq	1	{1}	1.00	\N	\N	\N	2
sport_freq	2	{2,3}	1.00	\N	\N	\N	12
sport_freq	3	{2,3}	1.00	\N	\N	\N	12
sport_freq	4	{0,1,2,3}	0.00	\N	\N	\N	15
soc_extra	0	{0,2,4}	1.00	\N	\N	\N	21
soc_extra	1	{1,2}	1.00	\N	\N	\N	6
soc_extra	2	{0,2,3,4}	1.00	\N	\N	\N	29
soc_extra	3	{0,1,2,3,4}	0.00	\N	\N	\N	31
soc_intro	0	{2,3}	1.00	\N	\N	\N	12
soc_intro	1	{0,1,3}	1.00	\N	\N	\N	11
soc_intro	2	{2}	1.00	\N	\N	\N	4
soc_intro	3	{0,1,2,3}	0.00	\N	\N	\N	15
soc_famille	0	{0}	2.00	\N	\N	\N	1
soc_famille	1	{1}	1.00	\N	\N	\N	2
soc_famille	2	{0,1}	0.00	\N	\N	\N	3
soc_amis	0	{0}	2.00	\N	\N	\N	1
soc_amis	1	{1}	1.00	\N	\N	\N	2
soc_amis	2	{0,1}	0.00	\N	\N	\N	3
fin_comport	0	{0,2,3}	1.00	\N	\N	\N	13
fin_comport	1	{1,2}	1.00	\N	\N	\N	6
fin_comport	2	{1,2}	1.00	\N	\N	\N	6
fin_comport	3	{0,1,2,3}	0.00	\N	\N	\N	15
fin_vision	0	{0,2}	1.00	\N	\N	\N	5
fin_vision	1	{1}	1.00	\N	\N	\N	2
fin_vision	2	{2}	1.00	\N	\N	\N	4
fin_vision	3	{0,1,2}	0.00	\N	\N	\N	7
mob_transp	1	{0,2}	1.00	\N	\N	\N	5
vice_conso	0	{0}	1.00	\N	\N	\N	1
vice_conso	1	{1}	1.00	\N	\N	\N	2
vice_conso	2	{2}	1.00	\N	\N	\N	4
com_integ	0	{0,1}	1.00	\N	\N	\N	3
com_integ	1	{1,3}	1.00	\N	\N	\N	10
com_integ	2	{2}	1.00	\N	\N	\N	4
com_integ	3	{0,1,2,3}	0.00	\N	\N	\N	15
com_drague	0	{0}	2.00	\N	\N	\N	1
com_drague	1	{1}	2.00	\N	\N	\N	2
com_ecoute	0	{0}	2.00	\N	\N	\N	1
com_ecoute	1	{2}	2.00	\N	\N	\N	4
com_ecoute	2	{1}	1.00	\N	\N	\N	2
com_emot	0	{0}	2.00	\N	\N	\N	1
com_emot	1	{2}	1.00	\N	\N	\N	4
com_emot	2	{1}	1.00	\N	\N	\N	2
com_emot	3	{0,1,2}	0.00	\N	\N	\N	7
com_humour	0	{0}	1.00	\N	\N	\N	1
com_humour	1	{1}	1.00	\N	\N	\N	2
com_humour	2	{2}	1.00	\N	\N	\N	4
com_humour	3	{3}	1.00	\N	\N	\N	8
com_canal	0	{1}	1.00	\N	\N	\N	2
com_canal	1	{2}	1.00	\N	\N	\N	4
com_canal	2	{0}	1.00	\N	\N	\N	1
com_conflit	0	{0}	2.00	\N	\N	\N	1
com_conflit	1	{1}	1.00	\N	\N	\N	2
com_conflit	2	{2}	1.00	\N	\N	\N	4
com_franchis	0	{0}	1.00	\N	\N	\N	1
com_franchis	1	{1,2}	1.00	\N	\N	\N	6
com_critiq	0	{1}	2.00	\N	\N	\N	2
com_critiq	1	{0}	2.00	\N	\N	\N	1
com_empathie	0	{0}	1.00	\N	\N	\N	1
com_empathie	1	{1}	1.00	\N	\N	\N	2
com_empathie	2	{0,1}	0.00	\N	\N	\N	3
psy_confianc	0	{0}	2.00	\N	\N	\N	1
psy_confianc	1	{1}	2.00	\N	\N	\N	2
psy_confianc	2	{0,1}	0.00	\N	\N	\N	3
psy_anxiete	0	{1}	1.00	\N	\N	\N	2
psy_anxiete	1	{0}	1.00	\N	\N	\N	1
psy_vision	0	{0}	2.00	\N	\N	\N	1
psy_curiosit	0	{0}	2.00	\N	\N	\N	1
psy_curiosit	1	{0,1}	0.00	\N	\N	\N	3
psy_creativ	0	{0}	1.00	\N	\N	\N	1
psy_creativ	1	{1}	1.00	\N	\N	\N	2
psy_creativ	2	{0,1}	0.00	\N	\N	\N	3
psy_competit	0	{0}	1.00	\N	\N	\N	1
psy_competit	1	{1}	1.00	\N	\N	\N	2
psy_action	0	{0}	1.00	\N	\N	\N	1
psy_action	1	{1}	1.00	\N	\N	\N	2
psy_action	2	{0,1}	0.00	\N	\N	\N	3
psy_risque	0	{0}	1.00	\N	\N	\N	1
psy_risque	1	{1}	1.00	\N	\N	\N	2
psy_ambition	0	{0}	2.00	\N	\N	\N	1
psy_ambition	1	{0,1}	1.00	\N	\N	\N	3
psy_humilite	0	{0}	2.00	\N	\N	\N	1
psy_humilite	1	{0,1}	0.00	\N	\N	\N	3
psy_humilite	2	{1}	1.00	\N	\N	\N	2
psy_control	0	{0}	1.00	\N	\N	\N	1
psy_control	1	{1}	1.00	\N	\N	\N	2
psy_adaptab	0	{0}	2.00	\N	\N	\N	1
psy_adaptab	1	{0,1}	0.00	\N	\N	\N	3
psy_spontan	0	{0}	1.00	\N	\N	\N	1
psy_spontan	1	{1}	2.00	\N	\N	\N	2
psy_discipli	0	{0}	1.00	\N	\N	\N	1
psy_discipli	1	{1}	1.00	\N	\N	\N	2
psy_persever	0	{0}	1.00	\N	\N	\N	1
psy_persever	1	{1}	1.00	\N	\N	\N	2
psy_respons	0	{0}	1.00	\N	\N	\N	1
psy_respons	1	{1}	1.00	\N	\N	\N	2
val_but	0	{0,4}	1.00	\N	\N	\N	17
val_but	1	{1,2,5}	1.00	\N	\N	\N	38
val_but	2	{3,5}	1.00	\N	\N	\N	40
val_but	3	{0,1,2,3,4,5}	0.00	\N	\N	\N	63
val_fidelite	0	{0}	2.00	\N	\N	\N	1
val_fidelite	1	{1}	1.00	\N	\N	\N	2
val_fidelite	2	{2}	1.00	\N	\N	\N	4
val_fidelite	3	{3}	1.00	\N	\N	\N	8
val_fidelite	4	{4}	2.00	\N	\N	\N	16
val_honnete	0	{0}	1.00	\N	\N	\N	1
val_honnete	1	{1}	1.00	\N	\N	\N	2
val_honnete	2	{2}	1.00	\N	\N	\N	4
val_honnete	3	{3}	1.00	\N	\N	\N	8
val_honnete	4	{4}	2.00	\N	\N	\N	16
val_spirit	0	{2,3,4}	2.00	\N	\N	\N	28
val_spirit	1	{0,1}	1.00	\N	\N	\N	3
val_spirit	2	{0,1,2,3,4}	1.00	\N	\N	\N	31
val_politique	0	{3,4}	2.00	\N	\N	\N	24
val_politique	1	{2}	1.00	\N	\N	\N	4
val_politique	2	{0,1}	1.00	\N	\N	\N	3
val_ecolo	0	{2,3,4}	2.00	\N	\N	\N	28
val_ecolo	1	{0,1}	1.00	\N	\N	\N	3
val_ecolo	2	{0,1,2,3,4}	0.00	\N	\N	\N	31
val_tradition	0	{2,3,4}	2.00	\N	\N	\N	28
val_tradition	1	{0,1}	1.00	\N	\N	\N	3
val_tradition	2	{0,1,2,3,4}	0.00	\N	\N	\N	31
val_culture	0	{2,3,4}	2.00	\N	\N	\N	28
val_culture	1	{0,1}	1.00	\N	\N	\N	3
val_culture	2	{0,1,2,3,4}	0.00	\N	\N	\N	31
val_etudes	0	{2,3,4,5}	2.00	\N	\N	\N	60
val_morale	0	{0}	1.00	\N	\N	\N	1
val_morale	1	{4}	1.00	\N	\N	\N	16
val_morale	2	{5}	1.00	\N	\N	\N	32
val_morale	4	{1}	1.00	\N	\N	\N	2
val_morale	5	{2}	1.00	\N	\N	\N	4
db_relation	0	{0}	2.00	\N	\N	\N	1
db_relation	1	{1}	2.00	\N	\N	\N	2
db_relation	2	{2}	2.00	\N	\N	\N	4
db_mariage	0	{0}	2.00	\N	\N	\N	1
db_mariage	1	{1,2}	2.00	\N	\N	\N	6
db_mariage	2	{0,1,2}	0.00	\N	\N	\N	7
db_enfants	0	{0}	2.00	\N	\N	\N	1
db_enfants	1	{1}	2.00	\N	\N	\N	2
db_enfants	2	{2}	1.00	\N	\N	\N	4
db_enfants	3	{0,1,2}	0.00	\N	\N	\N	7
cpl_dynamiq	0	{1}	1.00	\N	\N	\N	2
cpl_dynamiq	1	{0}	2.00	\N	\N	\N	1
cpl_fusion	0	{0}	1.00	\N	\N	\N	1
cpl_fusion	1	{1}	1.00	\N	\N	\N	2
cpl_affect	0	{0}	1.00	\N	\N	\N	1
cpl_affect	1	{1}	1.00	\N	\N	\N	2
cpl_affect	2	{0,1}	0.00	\N	\N	\N	3
cpl_espace	0	{1}	1.00	\N	\N	\N	2
cpl_espace	1	{0}	1.00	\N	\N	\N	1
cpl_jalous	0	{0}	1.00	\N	\N	\N	1
cpl_jalous	1	{1}	2.00	\N	\N	\N	2
proj_prio	0	{0}	1.00	\N	\N	\N	1
proj_prio	1	{1}	1.00	\N	\N	\N	2
proj_prio	2	{0,1}	0.00	\N	\N	\N	3
proj_statut	0	{0}	1.00	\N	\N	\N	1
proj_statut	1	{1}	1.00	\N	\N	\N	2
proj_statut	2	{0,1}	0.00	\N	\N	\N	3
proj_lieu	0	{0}	1.00	\N	\N	\N	1
proj_lieu	1	{1}	1.00	\N	\N	\N	2
proj_lieu	2	{0,1}	0.00	\N	\N	\N	3
proj_ancrage	0	{0}	1.00	\N	\N	\N	1
proj_ancrage	1	{1}	1.00	\N	\N	\N	2
proj_retraite	0	{0}	1.00	\N	\N	\N	1
proj_retraite	1	{1}	1.00	\N	\N	\N	2
proj_retraite	2	{2}	1.00	\N	\N	\N	4
proj_retraite	3	{3}	1.00	\N	\N	\N	8
proj_rythme	0	{0}	1.00	\N	\N	\N	1
proj_rythme	1	{1}	1.00	\N	\N	\N	2
db_regime	0	{0,1}	2.00	\N	\N	\N	3
animaux	0	{0,1,4,6}	1.00	\N	\N	\N	83
animaux	1	{2,3,5}	2.00	\N	\N	\N	44
animaux	2	{6}	1.00	\N	\N	\N	64
animaux	3	{0,1,2,3,4,5,6}	1.00	\N	\N	\N	127
db_regime	1	{0,1,2}	0.00	\N	\N	\N	7
db_relation	3	{0,1,2,3}	0.00	\N	\N	\N	15
db_relation	4	{3}	2.00	\N	\N	\N	8
mob_transp	0	{1,4}	1.00	\N	\N	\N	18
mob_transp	2	{0,1,2,3,4}	0.00	\N	\N	\N	31
psy_rigueur	0	{0}	1.00	\N	\N	\N	1
psy_rigueur	1	{1}	1.00	\N	\N	\N	2
psy_vision	1	{2}	1.00	\N	\N	\N	4
psy_vision	2	{0,1,2}	0.00	\N	\N	\N	7
val_morale	3	{6}	1.00	\N	\N	\N	64
val_morale	6	{3}	1.00	\N	\N	\N	8
vice_conso	3	{4}	2.00	\N	\N	\N	16
vice_conso	4	{3}	2.00	\N	\N	\N	8
val_etudes	1	{0,1,2,3,4,5}	0.00	\N	\N	\N	63
val_etudes	2	{3,4,5}	1.00	\N	\N	\N	56
val_etudes	3	{4,5}	1.00	\N	\N	\N	48
val_etudes	4	{5}	1.00	\N	\N	\N	32
phys_taille	12	{0,1,2,3,4,5,6,7,8,9}	0.00	\N	\N	\N	1023
phys_poids	10	{0,1,2,3,4,5,6,7,8,9}	0.00	\N	\N	\N	1023
phys_taille	11	{}	1.00	\N	inf	\N	0
val_etudes	5	{}	1.00	\N	sup	\N	0
val_etudes	6	{}	1.00	\N	inf	\N	0
val_etudes	7	{}	1.00	\N	egal	\N	0
\.


--
-- Data for Name: orders; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.orders (id, date_id, user_id, partner_id, status, created_at, sent_at, served_at) FROM stdin;
\.


--
-- Data for Name: partner_menu_categories; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_menu_categories (id, partner_id, label, "position") FROM stdin;
\.


--
-- Data for Name: partner_menu_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_menu_items (id, partner_id, category_id, label, description, price_cents, currency, is_available, "position") FROM stdin;
\.


--
-- Data for Name: order_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_items (id, order_id, menu_item_id, label_snapshot, unit_price_cents, quantity, options, created_at) FROM stdin;
\.


--
-- Data for Name: order_payments; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.order_payments (payment_id, order_id) FROM stdin;
\.


--
-- Data for Name: outstanding_debts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.outstanding_debts (id, user_id, date_id, partner_id, amount_cents, created_at, settled_at, settlement_payment_id, relances) FROM stdin;
\.


--
-- Data for Name: partner_acceptances; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_acceptances (partner_id, policy_code, policy_version, accepted_at, ip_address) FROM stdin;
\.


--
-- Data for Name: partner_contracts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_contracts (partner_id, provider, provider_ref, document_sha256, status, signed_at) FROM stdin;
\.


--
-- Data for Name: partner_documents; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_documents (id, partner_id, doc_type, storage_path, status, checked_at, created_at) FROM stdin;
\.


--
-- Data for Name: partner_payout_accounts; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_payout_accounts (partner_id, stripe_account_id, charges_enabled, payouts_enabled, requirements_due, updated_at) FROM stdin;
\.


--
-- Data for Name: partner_photos; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_photos (id, partner_id, source, google_photo_reference, storage_path, "position", created_at) FROM stdin;
\.


--
-- Data for Name: partner_postal_verifications; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_postal_verifications (partner_id, code_sha256, sent_at, verified_at, attempts) FROM stdin;
\.


--
-- Data for Name: partner_safe_zones; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_safe_zones (id, partner_id, label, zone, validated, created_at) FROM stdin;
\.


--
-- Data for Name: partner_settlements; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_settlements (id, payment_id, partner_id, gross_cents, commission_cents, net_cents, stripe_transfer_id, transferred_at, created_at, tip_cents, commission_reportee_cents, garantie) FROM stdin;
\.


--
-- Data for Name: partner_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_steps (step, code, label, est_minutes, bloquante) FROM stdin;
1	langue	Choix de la langue	1	t
2	bienvenue	Écran de bienvenue	2	t
3	compte	Création du compte et validation du code	3	t
4	pays	Sélection du pays	1	t
5	infos	Informations générales	4	t
6	documents	Documents administratifs et fiche Google	5	t
7	eligibilite	Vérification des critères d'éligibilité	1	t
8	verif_entreprise	Vérification de l'entreprise	1	t
9	verif_postale	Vérification postale	2	t
10	juridique	Acceptation des documents juridiques	3	t
11	contrat	Signature électronique du contrat	5	t
12	menu	Création du menu	20	t
13	photos	Sélection des photos	5	t
14	reversements	Compte de reversement	6	t
15	formation	Formations obligatoires	25	t
16	activation	Activation du compte	1	t
\.


--
-- Data for Name: partner_step_completions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_step_completions (partner_id, step, completed_at) FROM stdin;
\.


--
-- Data for Name: training_modules; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.training_modules (code, titre, "position", obligatoire, video_path, score_min) FROM stdin;
fonctionnement	Le fonctionnement de Safe Date	1	t	\N	80
accueil	L'accueil des utilisateurs	2	t	\N	80
bonnes_pratiques	Les bonnes pratiques	3	t	\N	80
securite	Les règles de sécurité	4	t	\N	80
incidents	La gestion des incidents	5	t	\N	80
urgence	Les procédures d'urgence	6	t	\N	80
\.


--
-- Data for Name: partner_training_completions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.partner_training_completions (partner_id, module_code, quiz_score, completed_at) FROM stdin;
\.


--
-- Data for Name: platform_messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.platform_messages (id, user_id, code, titre, corps, actions, a_envoyer_a, envoye_at, lu_at, created_at) FROM stdin;
\.


--
-- Data for Name: profile_answers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profile_answers (user_id, criterion_key, option_idx, answered_at) FROM stdin;
d0000000-0000-4000-8000-000000000001	phys_taille_moi	{8}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	phys_taille_rech	{6}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	phys_poids_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	phys_poids_rech	{6}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	yeux_couleur_moi	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	yeux_couleur_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	yeux_lunettes_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	yeux_lunettes_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	chev_longueur_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	chev_longueur_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	chev_couleur_moi	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	chev_couleur_rech	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	pil_barbe_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	pil_barbe_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	pil_moustache_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	pil_moustache_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	pil_corps_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	pil_corps_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_vetement_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_vetement_rech	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_tatouages_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_tatouages_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_piercings_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_piercings_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_maquillage_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_maquillage_rec	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_parfum_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	style_parfum_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_sommeil_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_sommeil_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_horaires_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_horaires_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_energie_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_energie_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_orga_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_orga_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_objets_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_objets_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_cuisine_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_cuisine_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_proprete_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_proprete_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_manuel_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_manuel_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_ecrans_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_ecrans_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_job_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	life_job_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_num_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_num_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_cult_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_cult_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_amis_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_amis_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_arts_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_arts_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_passion_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_passion_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_benev_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	loisir_benev_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_aime_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_aime_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_style_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_style_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_prepa_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_prepa_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_paysage_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_paysage_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_transp_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_transp_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_expat_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	voyage_expat_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	sport_solo_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	sport_solo_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	sport_groupe_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	sport_groupe_rech	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	sport_eau_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	sport_eau_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	sport_freq_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	sport_freq_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_extra_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_extra_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_intro_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_intro_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_reseau_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_reseau_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_famille_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_famille_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_amis_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	soc_amis_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	fin_comport_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	fin_comport_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	fin_vision_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	fin_vision_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	mob_transp_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	mob_transp_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	animaux_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	animaux_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	vice_conso_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	vice_conso_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_integ_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_integ_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_drague_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_drague_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_ecoute_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_ecoute_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_emot_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_emot_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_humour_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_humour_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_canal_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_canal_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_conflit_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_conflit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_franchis_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_franchis_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_critiq_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_critiq_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_empathie_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_empathie_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_patienc_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	com_patienc_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_confianc_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_confianc_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_anxiete_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_anxiete_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_vision_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_vision_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_curiosit_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_curiosit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_creativ_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_creativ_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_rigueur_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_rigueur_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_competit_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_competit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_action_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_action_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_risque_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_risque_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_ambition_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_ambition_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_humilite_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_humilite_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_control_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_control_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_adaptab_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_adaptab_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_spontan_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_spontan_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_discipli_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_discipli_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_persever_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_persever_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_respons_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	psy_respons_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_but_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_but_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_fidelite_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_fidelite_rech	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_honnete_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_honnete_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_spirit_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_spirit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_politique_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_politique_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_ecolo_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_ecolo_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_tradition_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_tradition_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_culture_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_culture_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_etudes_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_etudes_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_morale_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	val_morale_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_dynamiq_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_dynamiq_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_fusion_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_fusion_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_affect_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_affect_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_espace_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_espace_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_jalous_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	cpl_jalous_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_prio_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_prio_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_statut_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_statut_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_lieu_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_lieu_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_ancrage_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_ancrage_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_retraite_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_retraite_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_rythme_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000001	proj_rythme_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	phys_taille_moi	{8}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	phys_taille_rech	{6}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	phys_poids_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	phys_poids_rech	{6}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	yeux_couleur_moi	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	yeux_couleur_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	yeux_lunettes_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	yeux_lunettes_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	chev_longueur_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	chev_longueur_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	chev_couleur_moi	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	chev_couleur_rech	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	pil_barbe_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	pil_barbe_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	pil_moustache_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	pil_moustache_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	pil_corps_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	pil_corps_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_vetement_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_vetement_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_tatouages_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_tatouages_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_piercings_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_piercings_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_maquillage_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_maquillage_rec	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_parfum_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	style_parfum_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_sommeil_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_sommeil_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_horaires_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_horaires_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_energie_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_energie_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_orga_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_orga_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_objets_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_objets_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_cuisine_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_cuisine_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_proprete_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_proprete_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_manuel_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_manuel_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_ecrans_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_ecrans_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_job_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	life_job_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_num_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_num_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_cult_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_cult_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_amis_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_amis_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_arts_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_arts_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_passion_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_passion_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_benev_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	loisir_benev_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_aime_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_aime_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_style_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_style_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_prepa_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_prepa_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_paysage_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_paysage_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_transp_moi	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_transp_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_expat_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	voyage_expat_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	sport_solo_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	sport_solo_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	sport_groupe_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	sport_groupe_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	sport_eau_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	sport_eau_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	sport_freq_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	sport_freq_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_extra_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_extra_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_intro_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_intro_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_reseau_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_reseau_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_famille_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_famille_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_amis_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	soc_amis_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	fin_comport_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	fin_comport_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	fin_vision_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	fin_vision_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	mob_transp_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	mob_transp_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	animaux_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	animaux_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	vice_conso_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	vice_conso_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_integ_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_integ_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_drague_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_drague_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_ecoute_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_ecoute_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_emot_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_emot_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_humour_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_humour_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_canal_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_canal_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_conflit_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_conflit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_franchis_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_franchis_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_critiq_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_critiq_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_empathie_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_empathie_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_patienc_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	com_patienc_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_confianc_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_confianc_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_anxiete_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_anxiete_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_vision_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_vision_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_curiosit_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_curiosit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_creativ_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_creativ_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_rigueur_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_rigueur_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_competit_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_competit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_action_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_action_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_risque_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_risque_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_ambition_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_ambition_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_humilite_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_humilite_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_control_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_control_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_adaptab_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_adaptab_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_spontan_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_spontan_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_discipli_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_discipli_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_persever_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_persever_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_respons_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	psy_respons_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_but_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_but_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_fidelite_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_fidelite_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_honnete_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_honnete_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_spirit_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_spirit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_politique_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_politique_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_ecolo_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_ecolo_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_tradition_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_tradition_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_culture_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_culture_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_etudes_moi	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_etudes_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_morale_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	val_morale_rech	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_dynamiq_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_dynamiq_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_fusion_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_fusion_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_affect_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_affect_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_espace_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_espace_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_jalous_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	cpl_jalous_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_prio_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_prio_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_statut_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_statut_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_lieu_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_lieu_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_ancrage_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_ancrage_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_retraite_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_retraite_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_rythme_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000003	proj_rythme_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-00000000000a	phys_poids_rech	{6}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	yeux_couleur_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	yeux_lunettes_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	yeux_lunettes_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	chev_longueur_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	chev_couleur_moi	{5}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	phys_taille_moi	{7}	2026-08-01 20:11:46.137272+00
d0000000-0000-4000-8000-00000000000a	phys_taille_rech	{8}	2026-08-01 20:11:50.624592+00
d0000000-0000-4000-8000-00000000000a	phys_poids_moi	{5}	2026-08-01 20:11:54.498251+00
d0000000-0000-4000-8000-00000000000a	yeux_couleur_moi	{0}	2026-08-01 20:13:10.05763+00
d0000000-0000-4000-8000-00000000000a	chev_longueur_moi	{1}	2026-08-01 20:13:35.688622+00
d0000000-0000-4000-8000-00000000000a	chev_couleur_rech	{4}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	pil_barbe_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	pil_barbe_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	pil_moustache_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	pil_moustache_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	pil_corps_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	pil_corps_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_vetement_moi	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_vetement_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_tatouages_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_tatouages_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_piercings_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_piercings_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_maquillage_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_maquillage_rec	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_parfum_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	style_parfum_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_sommeil_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_sommeil_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_horaires_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_horaires_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_energie_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_energie_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_orga_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_orga_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_objets_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_objets_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_cuisine_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_cuisine_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_proprete_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_proprete_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_manuel_moi	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_manuel_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_ecrans_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_ecrans_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_job_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	life_job_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_num_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_num_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_cult_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_cult_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_amis_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_amis_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_arts_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_arts_rech	{4}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_passion_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_passion_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_benev_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	loisir_benev_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_aime_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_aime_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_style_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_style_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_prepa_moi	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_prepa_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_paysage_moi	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_paysage_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_transp_moi	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_transp_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_expat_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	voyage_expat_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	sport_solo_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	sport_solo_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	sport_groupe_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	sport_groupe_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	sport_eau_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	sport_eau_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	sport_freq_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	sport_freq_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_extra_moi	{4}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_extra_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_intro_moi	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_intro_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_reseau_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_reseau_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_famille_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_famille_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_amis_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	soc_amis_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	fin_comport_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	fin_vision_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	mob_transp_moi	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	mob_transp_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	animaux_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_integ_moi	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_integ_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_drague_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_drague_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_ecoute_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_ecoute_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_emot_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_emot_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_humour_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_humour_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_canal_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_canal_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_conflit_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_conflit_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_franchis_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_franchis_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_critiq_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_critiq_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_empathie_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_empathie_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_patienc_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	com_patienc_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_confianc_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_confianc_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_anxiete_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_anxiete_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_vision_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_vision_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_curiosit_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_curiosit_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_creativ_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_creativ_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_rigueur_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_rigueur_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_competit_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_competit_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_action_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_action_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_risque_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_risque_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_ambition_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_ambition_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_humilite_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_humilite_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_control_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_control_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_adaptab_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_adaptab_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_spontan_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_spontan_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_discipli_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_discipli_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_persever_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_persever_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_respons_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	psy_respons_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_but_moi	{4}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_but_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_fidelite_moi	{4}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_fidelite_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_honnete_moi	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_honnete_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_spirit_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_spirit_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_politique_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_politique_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_ecolo_moi	{4}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_ecolo_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_tradition_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_tradition_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_culture_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	vice_conso_moi	{3}	2026-08-01 20:12:05.735493+00
d0000000-0000-4000-8000-00000000000a	animaux_moi	{3}	2026-08-01 20:06:10.808836+00
d0000000-0000-4000-8000-00000000000a	fin_vision_moi	{1}	2026-08-01 20:06:43.433624+00
d0000000-0000-4000-8000-00000000000a	vice_conso_rech	{0}	2026-08-01 20:12:07.413949+00
d0000000-0000-4000-8000-00000000000a	val_culture_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_etudes_moi	{5}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_etudes_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_morale_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	val_morale_rech	{3}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_dynamiq_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_dynamiq_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_fusion_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_fusion_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_affect_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_affect_rech	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_espace_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_espace_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_jalous_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	cpl_jalous_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_prio_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_prio_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_statut_moi	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_statut_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_lieu_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_lieu_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_ancrage_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_ancrage_rech	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_retraite_moi	{2}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_retraite_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_rythme_moi	{0}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	proj_rythme_rech	{1}	2026-08-01 16:48:45.974341+00
d0000000-0000-4000-8000-00000000000a	genre_rech	{1}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_sex_or_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_sex_or_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_relation_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_relation_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_mariage_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_mariage_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_enfants_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_enfants_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_regime_moi	{2}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	db_regime_rech	{1}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	genre_moi	{1}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	genre_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_sex_or_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_sex_or_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_relation_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_relation_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_mariage_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_mariage_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_enfants_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_enfants_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_regime_moi	{2}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	db_regime_rech	{1}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	val_religion_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000001	val_religion_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	genre_moi	{1}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	genre_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_sex_or_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_sex_or_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_relation_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_relation_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_mariage_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_mariage_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_enfants_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_enfants_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_regime_moi	{2}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	db_regime_rech	{1}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	val_religion_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000003	val_religion_rech	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-00000000000a	fin_comport_moi	{1}	2026-08-01 20:06:43.086936+00
d0000000-0000-4000-8000-00000000000a	val_religion_rech	{2}	2026-08-01 20:12:15.457103+00
d0000000-0000-4000-8000-00000000000a	genre_moi	{1}	2026-08-01 20:11:43.207082+00
d0000000-0000-4000-8000-00000000000a	val_religion_moi	{4}	2026-08-01 20:12:11.102346+00
d0000000-0000-4000-8000-000000000002	phys_taille_moi	{8}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	phys_taille_rech	{6}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	phys_poids_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	phys_poids_rech	{6}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	yeux_couleur_moi	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	yeux_couleur_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	yeux_lunettes_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	yeux_lunettes_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	chev_longueur_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	chev_longueur_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	chev_couleur_moi	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	chev_couleur_rech	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	pil_barbe_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	pil_barbe_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	pil_moustache_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	pil_moustache_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	pil_corps_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	pil_corps_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_vetement_moi	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_vetement_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_tatouages_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_tatouages_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_piercings_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_piercings_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_maquillage_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_maquillage_rec	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_parfum_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	style_parfum_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_sommeil_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_sommeil_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_horaires_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_horaires_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_energie_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_energie_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_orga_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_orga_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_objets_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_objets_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_cuisine_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_cuisine_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_proprete_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_proprete_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_manuel_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_manuel_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_ecrans_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_ecrans_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_job_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	life_job_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_num_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_num_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_cult_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_cult_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_amis_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_amis_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_arts_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_arts_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_passion_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_passion_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_benev_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	loisir_benev_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_aime_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_aime_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_style_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_style_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_prepa_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_prepa_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_paysage_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_paysage_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_transp_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_transp_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_expat_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	voyage_expat_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	sport_solo_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	sport_solo_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	sport_groupe_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	sport_groupe_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	sport_eau_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	sport_eau_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	sport_freq_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	sport_freq_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_extra_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_extra_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_intro_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_intro_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_reseau_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_reseau_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_famille_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_famille_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_amis_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	soc_amis_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	fin_comport_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	fin_comport_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	fin_vision_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	fin_vision_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	mob_transp_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	mob_transp_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	animaux_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	animaux_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	vice_conso_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	vice_conso_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_integ_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_integ_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_drague_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_drague_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_ecoute_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_ecoute_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_emot_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_emot_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_humour_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_humour_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_canal_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_canal_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_conflit_moi	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_conflit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_franchis_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_franchis_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_critiq_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_critiq_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_empathie_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_empathie_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_patienc_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	com_patienc_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_confianc_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_confianc_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_anxiete_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_anxiete_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_vision_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_vision_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_curiosit_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_curiosit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_creativ_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_creativ_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_rigueur_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_rigueur_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_competit_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_competit_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_action_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_action_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_risque_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_risque_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_ambition_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_ambition_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_humilite_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_humilite_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_control_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_control_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_adaptab_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_adaptab_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_spontan_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_spontan_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_discipli_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_discipli_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_persever_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_persever_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_respons_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	psy_respons_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_but_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_but_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_fidelite_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_fidelite_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_honnete_moi	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_honnete_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_religion_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_religion_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_spirit_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_spirit_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_politique_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_politique_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_ecolo_moi	{4}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_ecolo_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_tradition_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_tradition_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_culture_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_culture_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_etudes_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_etudes_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_morale_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	val_morale_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	db_relation_rech	{3}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	db_mariage_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	db_enfants_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	db_enfants_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_dynamiq_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_dynamiq_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_fusion_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_fusion_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_affect_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_affect_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_espace_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_espace_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_jalous_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	cpl_jalous_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_prio_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_prio_rech	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_statut_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_statut_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_lieu_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_lieu_rech	{2}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_ancrage_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_ancrage_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_retraite_moi	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_retraite_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_rythme_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	proj_rythme_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	db_regime_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	db_regime_rech	{1}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	db_sex_or_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	db_sex_or_rech	{5}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	genre_moi	{0}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000002	genre_rech	{1}	2026-08-01 16:49:18.539988+00
d0000000-0000-4000-8000-000000000002	db_mariage_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	db_relation_moi	{0}	2026-07-31 22:40:40.179996+00
d0000000-0000-4000-8000-000000000002	pil_sourcils_moi	{0}	2026-08-10 11:55:45.075697+00
\.


--
-- Data for Name: profile_exclusions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profile_exclusions (id, user_lo, user_hi, initiator, reason, source_request_id, created_at, expires_at) FROM stdin;
\.


--
-- Data for Name: profile_vectors; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.profile_vectors (user_id, self_mask, pref_mask, weight_mul, answered_self, answered_pref, refreshed_at) FROM stdin;
d0000000-0000-4000-8000-00000000000a	{2,128,32,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,NULL,NULL,1,2,32,NULL,NULL,4,4,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,8,2,1,4,1,1,2,1,1,1,2,1,8,1,4,4,1,4,2,2,4,1,1,8,8,8,1,2,4,4,1,16,8,2,1,2,2,2,8,8,8,8,2,1,1,1,4,2,4,1,2,2,1,1,2,1,1,1,1,1,1,1,1,2,2,1,1,1,2,16,16,8,16,1,1,16,2,1,32,4,1,1,1,1,2,1,2,2,2,2,1,1,4,1,4,1}	{2,256,64,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,NULL,1,8,16,NULL,NULL,8,1,2,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,8,1,3,2,2,3,3,3,2,3,5,15,2,5,2,1,4,12,15,8,7,3,4,6,4,2,2,8,8,7,12,6,15,2,3,2,15,5,31,83,1,3,1,2,2,4,4,2,1,2,3,2,1,2,1,3,1,2,1,1,2,1,2,2,1,2,2,1,1,63,4,4,124,3,24,28,31,28,63,64,1,1,1,1,1,3,2,1,2,2,2,1,2,2,7,1}	{1.0000,1.0000,1.0000,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0000,1.0,1.0,1.0000,1.0000,1.0000,1.0,1.0,1.0000,1.0000,1.0000,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0000,0.5000,0.0000,1.0000,1.0000,0.0000,0.0000,0.0000,1.0000,0.0000,1.0000,0.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,0.0000,1.0000,0.0000,0.0000,1.0000,1.0000,1.0000,1.0000,2.0000,1.0000,1.0000,2.0000,1.0000,1.0000,0.0000,1.0000,0.0000,1.0000,0.0000,1.0000,0.0000,1.0000,1.0000,1.0000,2.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,2.0000,0.0000,1.0000,2.0000,1.0000,2.0000,0.0000,1.0000,1.0000,1.0000,1.0000,1.0000,2.0000,1.0000,1.0000,2.0000,2.0000,1.0000,1.0000,1.0000,0.0000,1.0000,1.0000,1.0000,1.0000,2.0000,2.0000,0.0000,2.0000,0.0000,1.0000,2.0000,2.0000,2.0000,2.0000,1.0000,0.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,0.0000,1.0000}	106	106	2026-08-05 20:40:44.886716+00
d0000000-0000-4000-8000-000000000003	{2,256,4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,32,NULL,NULL,1,4,32,NULL,NULL,4,4,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,2,1,4,1,1,1,2,1,2,4,1,8,1,2,4,2,4,2,2,4,1,1,8,8,32,1,2,1,4,1,1,8,1,1,2,1,2,2,8,2,8,2,1,1,1,4,4,1,2,2,1,1,1,2,1,1,1,1,2,2,1,1,1,2,2,1,1,2,16,16,8,1,1,4,16,16,1,32,16,1,1,1,1,2,1,2,2,1,1,1,1,1,2,4,1}	{1,64,64,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,NULL,1,8,16,NULL,NULL,8,1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,1,2,3,4,2,3,3,1,2,3,5,7,1,5,6,1,7,12,1,2,5,3,4,6,4,2,1,8,8,7,12,6,15,2,2,2,6,2,31,83,16,3,1,2,2,1,4,2,1,2,3,2,1,2,1,3,3,1,2,1,2,1,2,2,1,2,2,1,2,38,1,4,31,3,24,28,3,3,63,2,1,1,1,2,1,2,2,1,2,2,1,2,2,1,7,1}	{1.0000,1.0000,1.0000,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0000,1.0,1.0,1.0000,1.0000,1.0000,1.0,1.0,1.0000,1.0000,1.0000,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0000,1.0000,0.0000,1.0000,1.0000,0.0000,0.0000,1.0000,1.0000,0.0000,1.0000,0.5000,1.0000,1.0000,1.0000,1.0000,0.0000,1.0000,1.0000,1.0000,2.0000,0.0000,1.0000,1.0000,1.0000,1.0000,2.0000,1.0000,1.0000,2.0000,1.0000,1.0000,0.0000,1.0000,1.0000,1.0000,1.0000,1.0000,0.0000,1.0000,2.0000,1.0000,2.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,2.0000,0.0000,1.0000,2.0000,1.0000,2.0000,0.0000,0.0000,1.0000,1.0000,1.0000,1.0000,2.0000,1.0000,1.0000,2.0000,2.0000,1.0000,1.0000,1.0000,1.0000,2.0000,1.0000,0.0000,1.0000,2.0000,2.0000,1.0000,1.0000,0.0000,1.0000,2.0000,2.0000,2.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,0.0000,1.0000}	106	106	2026-08-05 20:40:44.886716+00
d0000000-0000-4000-8000-000000000001	{2,256,4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,32,NULL,NULL,1,4,32,NULL,NULL,4,4,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,8,2,1,4,2,1,1,2,2,2,2,1,8,1,1,4,2,4,2,2,4,2,1,8,8,8,1,2,16,4,1,1,1,2,1,2,2,2,2,8,2,8,2,1,1,1,4,2,1,1,2,1,1,1,2,1,2,1,1,1,1,1,1,1,1,1,1,1,2,16,16,8,1,1,16,16,1,1,4,2,1,1,1,1,2,1,2,2,1,2,1,1,1,2,4,1}	{1,64,64,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,NULL,1,8,16,NULL,NULL,8,1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,16,3,3,1,1,3,3,2,2,3,5,14,1,5,2,1,2,12,1,8,5,3,4,6,4,2,2,8,31,15,12,6,15,2,2,2,13,7,31,83,4,3,1,2,2,8,4,2,1,2,3,2,1,1,1,3,3,2,2,1,2,1,2,2,1,2,2,1,2,63,16,4,31,3,24,28,28,31,60,64,1,1,1,1,1,2,2,1,1,2,3,1,2,1,7,1}	{1.0000,1.0000,1.0000,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0000,1.0,1.0,1.0000,1.0000,1.0000,1.0,1.0,1.0000,1.0000,1.0000,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0000,0.0000,0.0000,1.0000,1.0000,0.0000,0.0000,1.0000,1.0000,0.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,2.0000,0.0000,1.0000,1.0000,1.0000,1.0000,2.0000,1.0000,0.0000,0.0000,1.0000,1.0000,0.0000,1.0000,1.0000,1.0000,1.0000,0.0000,0.0000,1.0000,1.0000,1.0000,2.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,2.0000,0.0000,1.0000,2.0000,1.0000,2.0000,0.0000,0.0000,1.0000,1.0000,1.0000,1.0000,2.0000,1.0000,1.0000,2.0000,2.0000,1.0000,1.0000,1.0000,0.0000,2.0000,1.0000,0.0000,1.0000,2.0000,2.0000,2.0000,0.0000,2.0000,1.0000,2.0000,2.0000,2.0000,2.0000,1.0000,1.0000,1.0000,1.0000,1.0000,1.0000,0.0000,1.0000,1.0000,1.0000,0.0000,1.0000}	106	106	2026-08-08 18:16:22.739146+00
d0000000-0000-4000-8000-000000000002	{1,256,4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,32,NULL,NULL,1,4,32,NULL,NULL,4,4,1,1,NULL,NULL,NULL,NULL,NULL,NULL,NULL,32,2,1,4,2,1,2,1,2,1,4,1,8,1,2,4,4,4,2,2,4,1,1,8,8,4,1,2,2,4,1,2,4,1,1,2,2,2,4,8,2,8,2,1,1,1,4,4,2,1,2,2,1,1,2,1,2,1,1,1,2,1,1,1,1,2,1,1,2,16,16,8,1,1,2,16,1,1,1,1,1,1,1,1,2,2,2,2,2,1,1,1,2,1,1,1}	{2,64,64,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,NULL,NULL,1,8,16,NULL,NULL,8,1,4,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,2,1,3,8,1,3,3,2,2,3,5,12,15,5,6,1,1,12,1,8,5,3,4,6,4,2,3,8,16,7,12,6,15,2,2,2,15,2,31,83,2,3,1,2,2,1,4,2,1,2,3,2,1,1,1,3,3,2,1,1,2,1,2,2,1,2,2,1,2,63,1,4,31,3,24,28,28,3,60,64,15,1,1,1,1,2,2,2,1,2,3,2,2,2,7,31}	{1.0000,1.1679400000000000000000000,1.1679400000000000000000000,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.1679400000000000000000000,1.0,1.0,1.4746476250000000000000000,1.1679400000000000000000000,1.1679400000000000000000000,1.0,1.0,1.1679400000000000000000000,1.1679400000000000000000000,1.1679400000000000000000000,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.0,1.4165226250000000000000000,0.5839700000000000000000000,0.0000,1.1679400000000000000000000,1.3752726250000000000000000,0.0000,0.0000,1.5158976250000000000000000,1.2673150000000000000000000,0.0000,1.4165226250000000000000000,2.3358800000000000000000000,0.0000,1.4746476250000000000000000,1.3752726250000000000000000,1.1679400000000000000000000,1.1266900000000000000000000,1.4746476250000000000000000,1.1679400000000000000000000,1.1679400000000000000000000,2.9492952500000000000000000,0.0000,1.1679400000000000000000000,1.1679400000000000000000000,1.1679400000000000000000000,1.1679400000000000000000000,0.0000,1.1679400000000000000000000,1.2673150000000000000000000,2.9492952500000000000000000,1.1679400000000000000000000,1.1679400000000000000000000,0.0000,1.2260650000000000000000000,1.1679400000000000000000000,1.4746476250000000000000000,0.0000,1.4746476250000000000000000,0.0000,1.1679400000000000000000000,1.5065226250000000000000000,1.1679400000000000000000000,2.3358800000000000000000000,1.1679400000000000000000000,1.1679400000000000000000000,1.4746476250000000000000000,1.4746476250000000000000000,1.2260650000000000000000000,1.5158976250000000000000000,2.8330452500000000000000000,0.0000,1.1266900000000000000000000,2.9492952500000000000000000,1.4746476250000000000000000,3.50000,0.0000,0.0000,1.1679400000000000000000000,1.4746476250000000000000000,1.2260650000000000000000000,1.4165226250000000000000000,2.9492952500000000000000000,1.1679400000000000000000000,1.1266900000000000000000000,2.5346300000000000000000000,2.8330452500000000000000000,1.1679400000000000000000000,1.4746476250000000000000000,1.4746476250000000000000000,0.0000,2.3358800000000000000000000,1.1679400000000000000000000,0.0000,1.4652726250000000000000000,2.6096300000000000000000000,2.9492952500000000000000000,2.8330452500000000000000000,1.4746476250000000000000000,2.9492952500000000000000000,1.1679400000000000000000000,0.0000,2.0000,2.0000,2.9492952500000000000000000,1.1679400000000000000000000,1.1679400000000000000000000,1.4746476250000000000000000,2.9492952500000000000000000,1.5158976250000000000000000,1.2260650000000000000000000,0.0000,1.1679400000000000000000000,1.1679400000000000000000000,1.5158976250000000000000000,0.0000,0.0000}	107	106	2026-08-10 12:03:13.86567+00
\.


--
-- Data for Name: quiz_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quiz_sessions (id, date_id, started_at, ended_at) FROM stdin;
\.


--
-- Data for Name: quiz_questions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quiz_questions (id, session_id, ordre, question, source_pair_key, options, created_at) FROM stdin;
\.


--
-- Data for Name: quiz_answers; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quiz_answers (question_id, user_id, answer_idx, answer_text, answered_at) FROM stdin;
\.


--
-- Data for Name: sensitive_access_log; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.sensitive_access_log (id, occurred_at, actor, subject_id, category, purpose, row_count) FROM stdin;
\.


--
-- Data for Name: session_messages; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.session_messages (id, message, actif) FROM stdin;
1	Votre profil est encore plus précis qu'hier.	t
2	Safe Date comprend désormais encore mieux vos préférences.	t
3	Votre moteur de compatibilité continue de gagner en précision.	t
4	Vos futures recommandations seront encore plus personnalisées.	t
5	Nous découvrons progressivement ce qui vous correspond vraiment.	t
6	Votre profil évolue à chaque session.	t
7	Nous affinons progressivement votre profil.	t
8	Votre profil devient de plus en plus fidèle à votre personnalité.	t
9	Nous avons identifié de nouvelles préférences aujourd'hui.	t
10	Chaque session améliore la qualité de vos futures recommandations.	t
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: surprise_cooldowns; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.surprise_cooldowns (from_user, to_user, blocked_until, reason) FROM stdin;
\.


--
-- Data for Name: surprise_proposals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.surprise_proposals (id, from_user, to_user, previous_date_id, response, created_at, responded_at) FROM stdin;
\.


--
-- Data for Name: swipe_ecrans; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.swipe_ecrans (swipe_id, ecran, duree_ms, consultations) FROM stdin;
\.


--
-- Data for Name: user_acceptances; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_acceptances (user_id, policy_code, policy_version, accepted_at, ip_address) FROM stdin;
\.


--
-- Data for Name: user_context_weights; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_context_weights (user_id, type_rencontre, poids_physique, poids_mode_vie, poids_valeurs, seuil_exigence, observations, confiance, updated_at) FROM stdin;
\.


--
-- Data for Name: user_criterion_learning; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_criterion_learning (user_id, pair_key, confirmations, contradictions, learned_mul, observations, updated_at) FROM stdin;
d0000000-0000-4000-8000-000000000002	pil_barbe	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	pil_corps	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	style_vetement	23.091850	11.984580	1.4165226250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	style_maquillage	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	style_parfum	22.091850	12.084580	1.3752726250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	life_energie	22.841850	9.084580	1.5158976250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	animaux	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	voyage_paysage	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	vice_conso	22.591850	9.084580	1.5065226250000000000000	187	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_vision	123.0958000	91.424510	1.75	218	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_rigueur	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	val_politique	91.595800	83.467400	1.3048150000000000000000	187	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	soc_reseau	90.595800	84.567400	1.2260650000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	val_etudes	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_patienc	90.845800	87.467400	1.1266900000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	val_morale	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	phys_taille	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	phys_poids	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	pil_moustache	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	style_tatouages	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	life_orga	91.595800	84.467400	1.2673150000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	life_cuisine	23.091850	11.984580	1.4165226250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	life_proprete	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	life_ecrans	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	life_job	22.091850	12.084580	1.3752726250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	loisir_num	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	loisir_cult	90.845800	87.467400	1.1266900000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	loisir_amis	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	loisir_arts	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	loisir_passion	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	loisir_benev	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	voyage_style	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	voyage_prepa	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	voyage_transp	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	sport_solo	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	sport_groupe	91.595800	84.467400	1.2673150000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	sport_eau	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	sport_freq	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	soc_extra	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	soc_famille	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	soc_amis	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	fin_vision	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_integ	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_drague	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_ecoute	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_emot	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_humour	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_canal	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_conflit	90.595800	84.567400	1.2260650000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_franchis	22.841850	9.084580	1.5158976250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	com_critiq	23.091850	11.984580	1.4165226250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_confianc	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_anxiete	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_competit	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_action	90.595800	84.567400	1.2260650000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_risque	23.091850	11.984580	1.4165226250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_ambition	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_humilite	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_control	90.845800	87.467400	1.1266900000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_adaptab	91.595800	84.467400	1.2673150000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_spontan	23.091850	11.984580	1.4165226250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_discipli	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_persever	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	psy_respons	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	val_fidelite	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	val_honnete	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	val_ecolo	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	val_tradition	23.091850	11.984580	1.4165226250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	val_culture	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	cpl_dynamiq	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	cpl_fusion	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	cpl_affect	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	cpl_espace	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	cpl_jalous	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	proj_prio	22.841850	9.084580	1.5158976250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	proj_statut	90.595800	84.567400	1.2260650000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	proj_ancrage	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	proj_retraite	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	proj_rythme	22.841850	9.084580	1.5158976250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	val_spirit	21.591850	9.184580	1.4652726250000000000000	187	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	yeux_couleur	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	yeux_lunettes	21.841850	9.184580	1.4746476250000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	chev_longueur	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
d0000000-0000-4000-8000-000000000002	chev_couleur	91.845800	87.367400	1.1679400000000000000000	188	2026-08-10 12:03:13.86567+00
\.


--
-- Data for Name: user_criterion_priorities; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_criterion_priorities (user_id, pair_key, rang, manuel) FROM stdin;
\.


--
-- Data for Name: user_criterion_profile; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_criterion_profile (user_id, criterion_key, grp, observations, taux_oui, taux_recent, importance, confiance, derive, updated_at) FROM stdin;
\.


--
-- Data for Name: user_knowledge_history; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_knowledge_history (user_id, jour, niveau) FROM stdin;
\.


--
-- Data for Name: user_option_outcome; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_option_outcome (user_id, criterion_key, option_idx, rencontres, satisfaction_moy, poursuites, taux_poursuite, pouvoir_predictif, confiance, updated_at) FROM stdin;
\.


--
-- Data for Name: user_option_stats; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_option_stats (user_id, criterion_key, option_idx, observations, oui, poids, poids_oui, obs_recentes, oui_recents, derniere_vue, updated_at) FROM stdin;
\.


--
-- Data for Name: user_payment_methods; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_payment_methods (user_id, stripe_customer_id, stripe_payment_method_id, brand, last4, exp_month, exp_year, is_default, created_at) FROM stdin;
\.


--
-- Data for Name: user_steps; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_steps (step, code, label, est_seconds, bloquante) FROM stdin;
1	langue	Choix de la langue	10	t
2	bienvenue	Écran de bienvenue	20	t
3	compte	Création du compte et validation du code	45	t
4	pays	Sélection du pays	10	t
5	questionnaire	Questionnaire initial	60	t
6	photos	Téléchargement des photos	30	t
7	biometrie	Vérification biométrique	25	t
8	juridique	Validation juridique et activation	20	t
9	geoloc	Autorisation de la géolocalisation	15	f
\.


--
-- Data for Name: user_step_completions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_step_completions (user_id, step, completed_at) FROM stdin;
d0000000-0000-4000-8000-00000000000a	5	2026-08-01 20:16:26.180485+00
\.


--
-- Data for Name: user_verification_codes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_verification_codes (user_id, channel, destination, code_sha256, sent_at, expires_at, verified_at, attempts) FROM stdin;
\.


--
-- Data for Name: venue_proposals; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.venue_proposals (id, conversation_id, partner_id, ordre, creneau_debut, score_pertinence, status, created_at) FROM stdin;
\.


--
-- Data for Name: venue_reviews; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.venue_reviews (date_id, user_id, partner_id, note_produits, note_rapport_qp, note_service, note_globale, commentaire, publier_google, status, created_at, submitted_at) FROM stdin;
\.


--
-- Data for Name: venue_votes; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.venue_votes (proposal_id, user_id, accepted, decided_at, duree_ms) FROM stdin;
\.


--
-- Name: invoice_number_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.invoice_number_seq', 1, false);


--
-- Name: profile_presentations_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.profile_presentations_id_seq', 27, true);


--
-- Name: sensitive_access_log_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sensitive_access_log_id_seq', 1, false);


--
-- Name: session_messages_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.session_messages_id_seq', 10, true);


--
-- Name: swipe_decisions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.swipe_decisions_id_seq', 414, true);


--
-- PostgreSQL database dump complete
--

\unrestrict oQI5XYFRFsKA58tVqnSY9yGFuyWx5ktpLOOHcbzIcXVrhxuoEklneuLiRAKxzkB

