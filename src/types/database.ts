export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      blocks: {
        Row: {
          blocked_id: string
          blocker_id: string
          created_at: string
        }
        Insert: {
          blocked_id: string
          blocker_id: string
          created_at?: string
        }
        Update: {
          blocked_id?: string
          blocker_id?: string
          created_at?: string
        }
        Relationships: []
      }
      consents: {
        Row: {
          category: Database["public"]["Enums"]["sensitive_category"]
          granted_at: string
          ip_address: unknown
          policy_code: string
          policy_version: string
          user_agent: string | null
          user_id: string
          withdrawn_at: string | null
        }
        Insert: {
          category: Database["public"]["Enums"]["sensitive_category"]
          granted_at?: string
          ip_address?: unknown
          policy_code: string
          policy_version: string
          user_agent?: string | null
          user_id: string
          withdrawn_at?: string | null
        }
        Update: {
          category?: Database["public"]["Enums"]["sensitive_category"]
          granted_at?: string
          ip_address?: unknown
          policy_code?: string
          policy_version?: string
          user_agent?: string | null
          user_id?: string
          withdrawn_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "consents_policy_code_policy_version_fkey"
            columns: ["policy_code", "policy_version"]
            isOneToOne: false
            referencedRelation: "policy_documents"
            referencedColumns: ["code", "version"]
          },
        ]
      }
      criteria: {
        Row: {
          category: string
          cluster: string | null
          direction: Database["public"]["Enums"]["criterion_direction"]
          key: string
          moment: Database["public"]["Enums"]["collection_moment"]
          multi_select: boolean
          ord: number
          pair_key: string
          question: string
          sensitive_category:
            | Database["public"]["Enums"]["sensitive_category"]
            | null
          subcategory: string
        }
        Insert: {
          category: string
          cluster?: string | null
          direction: Database["public"]["Enums"]["criterion_direction"]
          key: string
          moment: Database["public"]["Enums"]["collection_moment"]
          multi_select?: boolean
          ord: number
          pair_key: string
          question: string
          sensitive_category?:
            | Database["public"]["Enums"]["sensitive_category"]
            | null
          subcategory: string
        }
        Update: {
          category?: string
          cluster?: string | null
          direction?: Database["public"]["Enums"]["criterion_direction"]
          key?: string
          moment?: Database["public"]["Enums"]["collection_moment"]
          multi_select?: boolean
          ord?: number
          pair_key?: string
          question?: string
          sensitive_category?:
            | Database["public"]["Enums"]["sensitive_category"]
            | null
          subcategory?: string
        }
        Relationships: []
      }
      criterion_option_phrasings: {
        Row: {
          criterion_key: string
          idx: number
          locale: string
          phrase: string
        }
        Insert: {
          criterion_key: string
          idx: number
          locale?: string
          phrase: string
        }
        Update: {
          criterion_key?: string
          idx?: number
          locale?: string
          phrase?: string
        }
        Relationships: [
          {
            foreignKeyName: "criterion_option_phrasings_criterion_key_idx_fkey"
            columns: ["criterion_key", "idx"]
            isOneToOne: false
            referencedRelation: "criterion_options"
            referencedColumns: ["criterion_key", "idx"]
          },
        ]
      }
      criterion_options: {
        Row: {
          criterion_key: string
          idx: number
          is_neutral: boolean
          label: string
          unit: string | null
          value_max: number | null
          value_min: number | null
        }
        Insert: {
          criterion_key: string
          idx: number
          is_neutral?: boolean
          label: string
          unit?: string | null
          value_max?: number | null
          value_min?: number | null
        }
        Update: {
          criterion_key?: string
          idx?: number
          is_neutral?: boolean
          label?: string
          unit?: string | null
          value_max?: number | null
          value_min?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "criterion_options_criterion_key_fkey"
            columns: ["criterion_key"]
            isOneToOne: false
            referencedRelation: "criteria"
            referencedColumns: ["key"]
          },
        ]
      }
      criterion_pairs: {
        Row: {
          base_weight: number
          category: string
          cluster: string | null
          grp: Database["public"]["Enums"]["score_group"]
          is_absolute: boolean
          mapping_validated: boolean
          match_type: Database["public"]["Enums"]["match_type"]
          pair_key: string
          pref_key: string
          self_key: string
          slot: number
        }
        Insert: {
          base_weight?: number
          category: string
          cluster?: string | null
          grp: Database["public"]["Enums"]["score_group"]
          is_absolute?: boolean
          mapping_validated?: boolean
          match_type: Database["public"]["Enums"]["match_type"]
          pair_key: string
          pref_key: string
          self_key: string
          slot: number
        }
        Update: {
          base_weight?: number
          category?: string
          cluster?: string | null
          grp?: Database["public"]["Enums"]["score_group"]
          is_absolute?: boolean
          mapping_validated?: boolean
          match_type?: Database["public"]["Enums"]["match_type"]
          pair_key?: string
          pref_key?: string
          self_key?: string
          slot?: number
        }
        Relationships: [
          {
            foreignKeyName: "criterion_pairs_pref_key_fkey"
            columns: ["pref_key"]
            isOneToOne: false
            referencedRelation: "criteria"
            referencedColumns: ["key"]
          },
          {
            foreignKeyName: "criterion_pairs_self_key_fkey"
            columns: ["self_key"]
            isOneToOne: false
            referencedRelation: "criteria"
            referencedColumns: ["key"]
          },
        ]
      }
      date_meeting_points: {
        Row: {
          arrivee_at: string
          date_id: string
          expires_at: string
          point: unknown
          revealed_at: string | null
          user_id: string
        }
        Insert: {
          arrivee_at: string
          date_id: string
          expires_at: string
          point: unknown
          revealed_at?: string | null
          user_id: string
        }
        Update: {
          arrivee_at?: string
          date_id?: string
          expires_at?: string
          point?: unknown
          revealed_at?: string | null
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "date_meeting_points_date_id_fkey"
            columns: ["date_id"]
            isOneToOne: false
            referencedRelation: "dates"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "date_meeting_points_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      dates: {
        Row: {
          created_at: string
          creneau_debut: string
          id: string
          partner_id: string
          status: Database["public"]["Enums"]["date_status"]
          user_a: string
          user_b: string
        }
        Insert: {
          created_at?: string
          creneau_debut: string
          id?: string
          partner_id: string
          status?: Database["public"]["Enums"]["date_status"]
          user_a: string
          user_b: string
        }
        Update: {
          created_at?: string
          creneau_debut?: string
          id?: string
          partner_id?: string
          status?: Database["public"]["Enums"]["date_status"]
          user_a?: string
          user_b?: string
        }
        Relationships: [
          {
            foreignKeyName: "dates_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: false
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "dates_user_a_fkey"
            columns: ["user_a"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "dates_user_b_fkey"
            columns: ["user_b"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      deletion_requests: {
        Row: {
          cancelled_at: string | null
          execute_after: string
          executed_at: string | null
          requested_at: string
          user_id: string
        }
        Insert: {
          cancelled_at?: string | null
          execute_after?: string
          executed_at?: string | null
          requested_at?: string
          user_id: string
        }
        Update: {
          cancelled_at?: string | null
          execute_after?: string
          executed_at?: string | null
          requested_at?: string
          user_id?: string
        }
        Relationships: []
      }
      engine_params: {
        Row: {
          description: string
          key: string
          updated_at: string
          value: number
        }
        Insert: {
          description: string
          key: string
          updated_at?: string
          value: number
        }
        Update: {
          description?: string
          key?: string
          updated_at?: string
          value?: number
        }
        Relationships: []
      }
      identity_verifications: {
        Row: {
          age_estimated: number | null
          checked_at: string | null
          comparison_ok: boolean | null
          comparison_score: number | null
          created_at: string
          id: string
          liveness_ok: boolean | null
          photo_id: string | null
          provider: string
          provider_ref: string
          status: Database["public"]["Enums"]["verification_status"]
          user_id: string
        }
        Insert: {
          age_estimated?: number | null
          checked_at?: string | null
          comparison_ok?: boolean | null
          comparison_score?: number | null
          created_at?: string
          id?: string
          liveness_ok?: boolean | null
          photo_id?: string | null
          provider: string
          provider_ref: string
          status?: Database["public"]["Enums"]["verification_status"]
          user_id: string
        }
        Update: {
          age_estimated?: number | null
          checked_at?: string | null
          comparison_ok?: boolean | null
          comparison_score?: number | null
          created_at?: string
          id?: string
          liveness_ok?: boolean | null
          photo_id?: string | null
          provider?: string
          provider_ref?: string
          status?: Database["public"]["Enums"]["verification_status"]
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "identity_verifications_photo_id_fkey"
            columns: ["photo_id"]
            isOneToOne: false
            referencedRelation: "user_photos"
            referencedColumns: ["id"]
          },
        ]
      }
      menu_stopwords: {
        Row: {
          mot: string
        }
        Insert: {
          mot: string
        }
        Update: {
          mot?: string
        }
        Relationships: []
      }
      option_mappings: {
        Row: {
          accepted_self_idx: number[]
          pair_key: string
          pref_idx: number
          tolerance: number | null
          weight_multiplier: number
        }
        Insert: {
          accepted_self_idx?: number[]
          pair_key: string
          pref_idx: number
          tolerance?: number | null
          weight_multiplier?: number
        }
        Update: {
          accepted_self_idx?: number[]
          pair_key?: string
          pref_idx?: number
          tolerance?: number | null
          weight_multiplier?: number
        }
        Relationships: [
          {
            foreignKeyName: "option_mappings_pair_key_fkey"
            columns: ["pair_key"]
            isOneToOne: false
            referencedRelation: "criterion_pairs"
            referencedColumns: ["pair_key"]
          },
        ]
      }
      partner_acceptances: {
        Row: {
          accepted_at: string
          ip_address: unknown
          partner_id: string
          policy_code: string
          policy_version: string
        }
        Insert: {
          accepted_at?: string
          ip_address?: unknown
          partner_id: string
          policy_code: string
          policy_version: string
        }
        Update: {
          accepted_at?: string
          ip_address?: unknown
          partner_id?: string
          policy_code?: string
          policy_version?: string
        }
        Relationships: [
          {
            foreignKeyName: "partner_acceptances_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: false
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "partner_acceptances_policy_code_policy_version_fkey"
            columns: ["policy_code", "policy_version"]
            isOneToOne: false
            referencedRelation: "policy_documents"
            referencedColumns: ["code", "version"]
          },
        ]
      }
      partner_contracts: {
        Row: {
          document_sha256: string
          partner_id: string
          provider: string
          provider_ref: string
          signed_at: string | null
          status: Database["public"]["Enums"]["verification_status"]
        }
        Insert: {
          document_sha256: string
          partner_id: string
          provider: string
          provider_ref: string
          signed_at?: string | null
          status?: Database["public"]["Enums"]["verification_status"]
        }
        Update: {
          document_sha256?: string
          partner_id?: string
          provider?: string
          provider_ref?: string
          signed_at?: string | null
          status?: Database["public"]["Enums"]["verification_status"]
        }
        Relationships: [
          {
            foreignKeyName: "partner_contracts_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: true
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
        ]
      }
      partner_documents: {
        Row: {
          checked_at: string | null
          created_at: string
          doc_type: string
          id: string
          partner_id: string
          status: Database["public"]["Enums"]["verification_status"]
          storage_path: string
        }
        Insert: {
          checked_at?: string | null
          created_at?: string
          doc_type: string
          id?: string
          partner_id: string
          status?: Database["public"]["Enums"]["verification_status"]
          storage_path: string
        }
        Update: {
          checked_at?: string | null
          created_at?: string
          doc_type?: string
          id?: string
          partner_id?: string
          status?: Database["public"]["Enums"]["verification_status"]
          storage_path?: string
        }
        Relationships: [
          {
            foreignKeyName: "partner_documents_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: false
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
        ]
      }
      partner_menu_categories: {
        Row: {
          id: string
          label: string
          partner_id: string
          position: number
        }
        Insert: {
          id?: string
          label: string
          partner_id: string
          position?: number
        }
        Update: {
          id?: string
          label?: string
          partner_id?: string
          position?: number
        }
        Relationships: [
          {
            foreignKeyName: "partner_menu_categories_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: false
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
        ]
      }
      partner_menu_items: {
        Row: {
          category_id: string | null
          currency: string
          description: string | null
          id: string
          is_available: boolean
          label: string
          partner_id: string
          position: number
          price_cents: number
        }
        Insert: {
          category_id?: string | null
          currency?: string
          description?: string | null
          id?: string
          is_available?: boolean
          label: string
          partner_id: string
          position?: number
          price_cents: number
        }
        Update: {
          category_id?: string | null
          currency?: string
          description?: string | null
          id?: string
          is_available?: boolean
          label?: string
          partner_id?: string
          position?: number
          price_cents?: number
        }
        Relationships: [
          {
            foreignKeyName: "partner_menu_items_category_id_fkey"
            columns: ["category_id"]
            isOneToOne: false
            referencedRelation: "partner_menu_categories"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "partner_menu_items_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: false
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
        ]
      }
      partner_payout_accounts: {
        Row: {
          charges_enabled: boolean
          partner_id: string
          payouts_enabled: boolean
          requirements_due: string[]
          stripe_account_id: string
          updated_at: string
        }
        Insert: {
          charges_enabled?: boolean
          partner_id: string
          payouts_enabled?: boolean
          requirements_due?: string[]
          stripe_account_id: string
          updated_at?: string
        }
        Update: {
          charges_enabled?: boolean
          partner_id?: string
          payouts_enabled?: boolean
          requirements_due?: string[]
          stripe_account_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "partner_payout_accounts_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: true
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
        ]
      }
      partner_photos: {
        Row: {
          created_at: string
          google_photo_reference: string | null
          id: string
          partner_id: string
          position: number
          source: Database["public"]["Enums"]["photo_source"]
          storage_path: string | null
        }
        Insert: {
          created_at?: string
          google_photo_reference?: string | null
          id?: string
          partner_id: string
          position?: number
          source: Database["public"]["Enums"]["photo_source"]
          storage_path?: string | null
        }
        Update: {
          created_at?: string
          google_photo_reference?: string | null
          id?: string
          partner_id?: string
          position?: number
          source?: Database["public"]["Enums"]["photo_source"]
          storage_path?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "partner_photos_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: false
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
        ]
      }
      partner_postal_verifications: {
        Row: {
          attempts: number
          code_sha256: string
          partner_id: string
          sent_at: string
          verified_at: string | null
        }
        Insert: {
          attempts?: number
          code_sha256: string
          partner_id: string
          sent_at?: string
          verified_at?: string | null
        }
        Update: {
          attempts?: number
          code_sha256?: string
          partner_id?: string
          sent_at?: string
          verified_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "partner_postal_verifications_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: true
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
        ]
      }
      partner_safe_zones: {
        Row: {
          created_at: string
          id: string
          label: string
          partner_id: string
          validated: boolean
          zone: unknown
        }
        Insert: {
          created_at?: string
          id?: string
          label: string
          partner_id: string
          validated?: boolean
          zone: unknown
        }
        Update: {
          created_at?: string
          id?: string
          label?: string
          partner_id?: string
          validated?: boolean
          zone?: unknown
        }
        Relationships: [
          {
            foreignKeyName: "partner_safe_zones_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: false
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
        ]
      }
      partner_step_completions: {
        Row: {
          completed_at: string
          partner_id: string
          step: number
        }
        Insert: {
          completed_at?: string
          partner_id: string
          step: number
        }
        Update: {
          completed_at?: string
          partner_id?: string
          step?: number
        }
        Relationships: [
          {
            foreignKeyName: "partner_step_completions_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: false
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "partner_step_completions_step_fkey"
            columns: ["step"]
            isOneToOne: false
            referencedRelation: "partner_steps"
            referencedColumns: ["step"]
          },
        ]
      }
      partner_steps: {
        Row: {
          bloquante: boolean
          code: string
          est_minutes: number
          label: string
          step: number
        }
        Insert: {
          bloquante?: boolean
          code: string
          est_minutes?: number
          label: string
          step: number
        }
        Update: {
          bloquante?: boolean
          code?: string
          est_minutes?: number
          label?: string
          step?: number
        }
        Relationships: []
      }
      partner_training_completions: {
        Row: {
          completed_at: string
          module_code: string
          partner_id: string
          passed: boolean | null
          quiz_score: number
        }
        Insert: {
          completed_at?: string
          module_code: string
          partner_id: string
          passed?: boolean | null
          quiz_score: number
        }
        Update: {
          completed_at?: string
          module_code?: string
          partner_id?: string
          passed?: boolean | null
          quiz_score?: number
        }
        Relationships: [
          {
            foreignKeyName: "partner_training_completions_module_code_fkey"
            columns: ["module_code"]
            isOneToOne: false
            referencedRelation: "training_modules"
            referencedColumns: ["code"]
          },
          {
            foreignKeyName: "partner_training_completions_partner_id_fkey"
            columns: ["partner_id"]
            isOneToOne: false
            referencedRelation: "partners"
            referencedColumns: ["id"]
          },
        ]
      }
      partners: {
        Row: {
          activated_at: string | null
          adresse: string | null
          code_postal: string | null
          created_at: string
          email: string | null
          google_avis: number | null
          google_maps_url: string | null
          google_note: number | null
          google_place_id: string | null
          google_verifie_le: string | null
          id: string
          langue: string
          location: unknown
          motif_rejet: string | null
          nom_commercial: string | null
          owner_id: string
          pays: string
          raison_sociale: string | null
          site_web: string | null
          status: Database["public"]["Enums"]["partner_status"]
          telephone: string | null
          ville: string | null
        }
        Insert: {
          activated_at?: string | null
          adresse?: string | null
          code_postal?: string | null
          created_at?: string
          email?: string | null
          google_avis?: number | null
          google_maps_url?: string | null
          google_note?: number | null
          google_place_id?: string | null
          google_verifie_le?: string | null
          id?: string
          langue: string
          location?: unknown
          motif_rejet?: string | null
          nom_commercial?: string | null
          owner_id: string
          pays: string
          raison_sociale?: string | null
          site_web?: string | null
          status?: Database["public"]["Enums"]["partner_status"]
          telephone?: string | null
          ville?: string | null
        }
        Update: {
          activated_at?: string | null
          adresse?: string | null
          code_postal?: string | null
          created_at?: string
          email?: string | null
          google_avis?: number | null
          google_maps_url?: string | null
          google_note?: number | null
          google_place_id?: string | null
          google_verifie_le?: string | null
          id?: string
          langue?: string
          location?: unknown
          motif_rejet?: string | null
          nom_commercial?: string | null
          owner_id?: string
          pays?: string
          raison_sociale?: string | null
          site_web?: string | null
          status?: Database["public"]["Enums"]["partner_status"]
          telephone?: string | null
          ville?: string | null
        }
        Relationships: []
      }
      policy_documents: {
        Row: {
          body: string
          body_sha256: string
          code: string
          is_current: boolean
          published_at: string
          version: string
        }
        Insert: {
          body: string
          body_sha256: string
          code: string
          is_current?: boolean
          published_at: string
          version: string
        }
        Update: {
          body?: string
          body_sha256?: string
          code?: string
          is_current?: boolean
          published_at?: string
          version?: string
        }
        Relationships: []
      }
      profile_answers: {
        Row: {
          answered_at: string
          criterion_key: string
          option_idx: number[]
          user_id: string
        }
        Insert: {
          answered_at?: string
          criterion_key: string
          option_idx: number[]
          user_id: string
        }
        Update: {
          answered_at?: string
          criterion_key?: string
          option_idx?: number[]
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "profile_answers_criterion_key_fkey"
            columns: ["criterion_key"]
            isOneToOne: false
            referencedRelation: "criteria"
            referencedColumns: ["key"]
          },
          {
            foreignKeyName: "profile_answers_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profile_vectors: {
        Row: {
          answered_pref: number
          answered_self: number
          pref_mask: number[]
          refreshed_at: string
          self_mask: number[]
          user_id: string
          weight_mul: number[]
        }
        Insert: {
          answered_pref?: number
          answered_self?: number
          pref_mask: number[]
          refreshed_at?: string
          self_mask: number[]
          user_id: string
          weight_mul: number[]
        }
        Update: {
          answered_pref?: number
          answered_self?: number
          pref_mask?: number[]
          refreshed_at?: string
          self_mask?: number[]
          user_id?: string
          weight_mul?: number[]
        }
        Relationships: [
          {
            foreignKeyName: "profile_vectors_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          age_max: number
          age_min: number
          birth_date: string
          created_at: string
          geoloc_precise: boolean | null
          id: string
          is_active: boolean
          is_premium: boolean
          is_verified: boolean
          langue: string | null
          last_location: unknown
          pays: string | null
          prenom: string | null
          search_radius_km: number
          systeme_unites: Database["public"]["Enums"]["unit_system"]
        }
        Insert: {
          age_max?: number
          age_min?: number
          birth_date: string
          created_at?: string
          geoloc_precise?: boolean | null
          id: string
          is_active?: boolean
          is_premium?: boolean
          is_verified?: boolean
          langue?: string | null
          last_location?: unknown
          pays?: string | null
          prenom?: string | null
          search_radius_km?: number
          systeme_unites?: Database["public"]["Enums"]["unit_system"]
        }
        Update: {
          age_max?: number
          age_min?: number
          birth_date?: string
          created_at?: string
          geoloc_precise?: boolean | null
          id?: string
          is_active?: boolean
          is_premium?: boolean
          is_verified?: boolean
          langue?: string | null
          last_location?: unknown
          pays?: string | null
          prenom?: string | null
          search_radius_km?: number
          systeme_unites?: Database["public"]["Enums"]["unit_system"]
        }
        Relationships: []
      }
      reports: {
        Row: {
          created_at: string
          details: string | null
          handled_at: string | null
          handled_by: string | null
          id: string
          outcome: string | null
          reason: Database["public"]["Enums"]["report_reason"]
          reported_id: string | null
          reporter_id: string | null
          status: Database["public"]["Enums"]["report_status"]
        }
        Insert: {
          created_at?: string
          details?: string | null
          handled_at?: string | null
          handled_by?: string | null
          id?: string
          outcome?: string | null
          reason: Database["public"]["Enums"]["report_reason"]
          reported_id?: string | null
          reporter_id?: string | null
          status?: Database["public"]["Enums"]["report_status"]
        }
        Update: {
          created_at?: string
          details?: string | null
          handled_at?: string | null
          handled_by?: string | null
          id?: string
          outcome?: string | null
          reason?: Database["public"]["Enums"]["report_reason"]
          reported_id?: string | null
          reporter_id?: string | null
          status?: Database["public"]["Enums"]["report_status"]
        }
        Relationships: []
      }
      sensitive_access_log: {
        Row: {
          actor: string
          category: Database["public"]["Enums"]["sensitive_category"] | null
          id: number
          occurred_at: string
          purpose: string
          row_count: number | null
          subject_id: string | null
        }
        Insert: {
          actor: string
          category?: Database["public"]["Enums"]["sensitive_category"] | null
          id?: number
          occurred_at?: string
          purpose: string
          row_count?: number | null
          subject_id?: string | null
        }
        Update: {
          actor?: string
          category?: Database["public"]["Enums"]["sensitive_category"] | null
          id?: number
          occurred_at?: string
          purpose?: string
          row_count?: number | null
          subject_id?: string | null
        }
        Relationships: []
      }
      spatial_ref_sys: {
        Row: {
          auth_name: string | null
          auth_srid: number | null
          proj4text: string | null
          srid: number
          srtext: string | null
        }
        Insert: {
          auth_name?: string | null
          auth_srid?: number | null
          proj4text?: string | null
          srid: number
          srtext?: string | null
        }
        Update: {
          auth_name?: string | null
          auth_srid?: number | null
          proj4text?: string | null
          srid?: number
          srtext?: string | null
        }
        Relationships: []
      }
      swipe_decisions: {
        Row: {
          created_at: string
          decision: boolean
          duree_ms: number | null
          ecran: string | null
          id: number
          signal_fort: boolean
          target_id: string
          user_id: string
        }
        Insert: {
          created_at?: string
          decision: boolean
          duree_ms?: number | null
          ecran?: string | null
          id?: number
          signal_fort?: boolean
          target_id: string
          user_id: string
        }
        Update: {
          created_at?: string
          decision?: boolean
          duree_ms?: number | null
          ecran?: string | null
          id?: number
          signal_fort?: boolean
          target_id?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "swipe_decisions_target_id_fkey"
            columns: ["target_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "swipe_decisions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      training_modules: {
        Row: {
          code: string
          obligatoire: boolean
          position: number
          score_min: number
          titre: string
          video_path: string | null
        }
        Insert: {
          code: string
          obligatoire?: boolean
          position: number
          score_min?: number
          titre: string
          video_path?: string | null
        }
        Update: {
          code?: string
          obligatoire?: boolean
          position?: number
          score_min?: number
          titre?: string
          video_path?: string | null
        }
        Relationships: []
      }
      user_acceptances: {
        Row: {
          accepted_at: string
          ip_address: unknown
          policy_code: string
          policy_version: string
          user_id: string
        }
        Insert: {
          accepted_at?: string
          ip_address?: unknown
          policy_code: string
          policy_version: string
          user_id: string
        }
        Update: {
          accepted_at?: string
          ip_address?: unknown
          policy_code?: string
          policy_version?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_acceptances_policy_code_policy_version_fkey"
            columns: ["policy_code", "policy_version"]
            isOneToOne: false
            referencedRelation: "policy_documents"
            referencedColumns: ["code", "version"]
          },
          {
            foreignKeyName: "user_acceptances_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_criterion_priorities: {
        Row: {
          manuel: boolean
          pair_key: string
          rang: number
          user_id: string
        }
        Insert: {
          manuel?: boolean
          pair_key: string
          rang: number
          user_id: string
        }
        Update: {
          manuel?: boolean
          pair_key?: string
          rang?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_criterion_priorities_pair_key_fkey"
            columns: ["pair_key"]
            isOneToOne: false
            referencedRelation: "criterion_pairs"
            referencedColumns: ["pair_key"]
          },
          {
            foreignKeyName: "user_criterion_priorities_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_photos: {
        Row: {
          created_at: string
          id: string
          is_primary: boolean
          moderated_at: string | null
          moderation: Database["public"]["Enums"]["moderation_status"]
          position: number
          storage_path: string
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          is_primary?: boolean
          moderated_at?: string | null
          moderation?: Database["public"]["Enums"]["moderation_status"]
          position?: number
          storage_path: string
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          is_primary?: boolean
          moderated_at?: string | null
          moderation?: Database["public"]["Enums"]["moderation_status"]
          position?: number
          storage_path?: string
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_photos_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_step_completions: {
        Row: {
          completed_at: string
          step: number
          user_id: string
        }
        Insert: {
          completed_at?: string
          step: number
          user_id: string
        }
        Update: {
          completed_at?: string
          step?: number
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_step_completions_step_fkey"
            columns: ["step"]
            isOneToOne: false
            referencedRelation: "user_steps"
            referencedColumns: ["step"]
          },
          {
            foreignKeyName: "user_step_completions_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: false
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
      user_steps: {
        Row: {
          bloquante: boolean
          code: string
          est_seconds: number
          label: string
          step: number
        }
        Insert: {
          bloquante?: boolean
          code: string
          est_seconds?: number
          label: string
          step: number
        }
        Update: {
          bloquante?: boolean
          code?: string
          est_seconds?: number
          label?: string
          step?: number
        }
        Relationships: []
      }
      user_verification_codes: {
        Row: {
          attempts: number
          channel: Database["public"]["Enums"]["verif_channel"]
          code_sha256: string
          destination: string
          expires_at: string
          sent_at: string
          user_id: string
          verified_at: string | null
        }
        Insert: {
          attempts?: number
          channel: Database["public"]["Enums"]["verif_channel"]
          code_sha256: string
          destination: string
          expires_at?: string
          sent_at?: string
          user_id: string
          verified_at?: string | null
        }
        Update: {
          attempts?: number
          channel?: Database["public"]["Enums"]["verif_channel"]
          code_sha256?: string
          destination?: string
          expires_at?: string
          sent_at?: string
          user_id?: string
          verified_at?: string | null
        }
        Relationships: [
          {
            foreignKeyName: "user_verification_codes_user_id_fkey"
            columns: ["user_id"]
            isOneToOne: true
            referencedRelation: "profiles"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      geography_columns: {
        Row: {
          coord_dimension: number | null
          f_geography_column: unknown
          f_table_catalog: unknown
          f_table_name: unknown
          f_table_schema: unknown
          srid: number | null
          type: string | null
        }
        Relationships: []
      }
      geometry_columns: {
        Row: {
          coord_dimension: number | null
          f_geometry_column: unknown
          f_table_catalog: string | null
          f_table_name: unknown
          f_table_schema: unknown
          srid: number | null
          type: string | null
        }
        Insert: {
          coord_dimension?: number | null
          f_geometry_column?: unknown
          f_table_catalog?: string | null
          f_table_name?: unknown
          f_table_schema?: unknown
          srid?: number | null
          type?: string | null
        }
        Update: {
          coord_dimension?: number | null
          f_geometry_column?: unknown
          f_table_catalog?: string | null
          f_table_name?: unknown
          f_table_schema?: unknown
          srid?: number | null
          type?: string | null
        }
        Relationships: []
      }
    }
    Functions: {
      _postgis_deprecate: {
        Args: { newname: string; oldname: string; version: string }
        Returns: undefined
      }
      _postgis_index_extent: {
        Args: { col: string; tbl: unknown }
        Returns: unknown
      }
      _postgis_pgsql_version: { Args: never; Returns: string }
      _postgis_scripts_pgsql_version: { Args: never; Returns: string }
      _postgis_selectivity: {
        Args: { att_name: string; geom: unknown; mode?: string; tbl: unknown }
        Returns: number
      }
      _postgis_stats: {
        Args: { ""?: string; att_name: string; tbl: unknown }
        Returns: string
      }
      _st_3dintersects: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_contains: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_containsproperly: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_coveredby:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      _st_covers:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      _st_crosses: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_dwithin: {
        Args: {
          geog1: unknown
          geog2: unknown
          tolerance: number
          use_spheroid?: boolean
        }
        Returns: boolean
      }
      _st_equals: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      _st_intersects: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_linecrossingdirection: {
        Args: { line1: unknown; line2: unknown }
        Returns: number
      }
      _st_longestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      _st_maxdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      _st_orderingequals: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_overlaps: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_sortablehash: { Args: { geom: unknown }; Returns: number }
      _st_touches: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      _st_voronoi: {
        Args: {
          clip?: unknown
          g1: unknown
          return_polygons?: boolean
          tolerance?: number
        }
        Returns: unknown
      }
      _st_within: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      activate_partner: { Args: { p: string }; Returns: undefined }
      activate_user: { Args: never; Returns: undefined }
      addauth: { Args: { "": string }; Returns: boolean }
      addgeometrycolumn:
        | {
            Args: {
              catalog_name: string
              column_name: string
              new_dim: number
              new_srid_in: number
              new_type: string
              schema_name: string
              table_name: string
              use_typmod?: boolean
            }
            Returns: string
          }
        | {
            Args: {
              column_name: string
              new_dim: number
              new_srid: number
              new_type: string
              schema_name: string
              table_name: string
              use_typmod?: boolean
            }
            Returns: string
          }
        | {
            Args: {
              column_name: string
              new_dim: number
              new_srid: number
              new_type: string
              table_name: string
              use_typmod?: boolean
            }
            Returns: string
          }
      answer_progress: {
        Args: never
        Returns: {
          criteres_evaluables: number
          onboarding_repondus: number
          onboarding_total: number
          paires_completes: number
          quiz_repondus: number
          quiz_total: number
        }[]
      }
      are_blocked: { Args: { a: string; b: string }; Returns: boolean }
      candidate_cards: {
        Args: never
        Returns: {
          affichable: boolean
          age: number
          au_dela_du_seuil: boolean
          candidate_id: string
          criteres_evalues: number
          filtres_ok: boolean
          highlights: Json
          photo: string
          prenom: string
          score_aller: number
          score_global: number
          score_mode_vie: number
          score_physique: number
          score_retour: number
          score_valeurs: number
          verifie: boolean
        }[]
      }
      check_partner_eligibility: {
        Args: { p: string }
        Returns: {
          eligible: boolean
          motif: string
        }[]
      }
      compat_score: {
        Args: { autre: string }
        Returns: {
          affichable: boolean
          criteres_evalues: number
          filtres_ok: boolean
          score_a_vers_b: number
          score_b_vers_a: number
          score_global: number
          score_mode_vie: number
          score_physique: number
          score_valeurs: number
        }[]
      }
      complete_questionnaire_step: { Args: never; Returns: undefined }
      consentements_requis_questionnaire: {
        Args: never
        Returns: {
          accorde: boolean
          categorie: Database["public"]["Enums"]["sensitive_category"]
          criteres: number
        }[]
      }
      diagnostic_zones: {
        Args: { p_id: string }
        Returns: {
          couple_possible: boolean
          ecart_max_m: number
          points_possibles: number
          zones_validees: number
        }[]
      }
      disablelongtransactions: { Args: never; Returns: string }
      dropgeometrycolumn:
        | {
            Args: {
              catalog_name: string
              column_name: string
              schema_name: string
              table_name: string
            }
            Returns: string
          }
        | {
            Args: {
              column_name: string
              schema_name: string
              table_name: string
            }
            Returns: string
          }
        | { Args: { column_name: string; table_name: string }; Returns: string }
      dropgeometrytable:
        | {
            Args: {
              catalog_name: string
              schema_name: string
              table_name: string
            }
            Returns: string
          }
        | { Args: { schema_name: string; table_name: string }; Returns: string }
        | { Args: { table_name: string }; Returns: string }
      eligible_candidates: {
        Args: never
        Returns: {
          candidate_id: string
        }[]
      }
      enablelongtransactions: { Args: never; Returns: string }
      equals: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      expirer_points_rendezvous: { Args: never; Returns: number }
      geometry: { Args: { "": string }; Returns: unknown }
      geometry_above: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_below: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_cmp: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      geometry_contained_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_contains: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_contains_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_distance_box: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      geometry_distance_centroid: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      geometry_eq: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_ge: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_gt: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_le: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_left: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_lt: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overabove: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overbelow: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overlaps: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overlaps_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overleft: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_overright: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_right: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_same: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_same_3d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geometry_within: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      geomfromewkt: { Args: { "": string }; Returns: unknown }
      gettransactionid: { Args: never; Returns: unknown }
      has_consent: {
        Args: {
          c: Database["public"]["Enums"]["sensitive_category"]
          u: string
        }
        Returns: boolean
      }
      longtransactionsenabled: { Args: never; Returns: boolean }
      menu_label_conflit: {
        Args: { label: string; p: string }
        Returns: string
      }
      next_questions: {
        Args: { n?: number }
        Returns: {
          criterion_key: string
          grp: Database["public"]["Enums"]["score_group"]
          moment: Database["public"]["Enums"]["collection_moment"]
          motif: string
          priorite: number
          question: string
        }[]
      }
      partner_activation_checklist: {
        Args: { p: string }
        Returns: {
          condition: string
          rang: number
          satisfaite: boolean
        }[]
      }
      partner_progress: {
        Args: { p: string }
        Returns: {
          etape_courante: number
          etapes_total: number
          minutes_restantes: number
          statut: Database["public"]["Enums"]["partner_status"]
        }[]
      }
      populate_geometry_columns:
        | { Args: { tbl_oid: unknown; use_typmod?: boolean }; Returns: number }
        | { Args: { use_typmod?: boolean }; Returns: string }
      postgis_constraint_dims: {
        Args: { geomcolumn: string; geomschema: string; geomtable: string }
        Returns: number
      }
      postgis_constraint_srid: {
        Args: { geomcolumn: string; geomschema: string; geomtable: string }
        Returns: number
      }
      postgis_constraint_type: {
        Args: { geomcolumn: string; geomschema: string; geomtable: string }
        Returns: string
      }
      postgis_extensions_upgrade: { Args: never; Returns: string }
      postgis_full_version: { Args: never; Returns: string }
      postgis_geos_version: { Args: never; Returns: string }
      postgis_lib_build_date: { Args: never; Returns: string }
      postgis_lib_revision: { Args: never; Returns: string }
      postgis_lib_version: { Args: never; Returns: string }
      postgis_libjson_version: { Args: never; Returns: string }
      postgis_liblwgeom_version: { Args: never; Returns: string }
      postgis_libprotobuf_version: { Args: never; Returns: string }
      postgis_libxml_version: { Args: never; Returns: string }
      postgis_proj_version: { Args: never; Returns: string }
      postgis_scripts_build_date: { Args: never; Returns: string }
      postgis_scripts_installed: { Args: never; Returns: string }
      postgis_scripts_released: { Args: never; Returns: string }
      postgis_svn_version: { Args: never; Returns: string }
      postgis_type_name: {
        Args: {
          coord_dimension: number
          geomname: string
          use_new_name?: boolean
        }
        Returns: string
      }
      postgis_version: { Args: never; Returns: string }
      postgis_wagyu_version: { Args: never; Returns: string }
      priorite_coef: { Args: { rang: number }; Returns: number }
      profile_header: {
        Args: never
        Returns: {
          age: number
          connaissance: number
          est_premium: boolean
          photo_principale: string
          profil_verifie: boolean
        }[]
      }
      profile_knowledge: { Args: never; Returns: number }
      profile_sections: {
        Args: never
        Returns: {
          ord: number
          pair_key: string
          phrase: string
          section: Database["public"]["Enums"]["score_group"]
        }[]
      }
      proximite_disponible: { Args: never; Returns: boolean }
      render_measure: {
        Args: {
          sys: Database["public"]["Enums"]["unit_system"]
          v_max: number
          v_min: number
          v_unit: string
        }
        Returns: string
      }
      reorder_priorities: { Args: { ordre: string[] }; Returns: undefined }
      request_account_deletion: { Args: never; Returns: undefined }
      reveal_establishment: {
        Args: { d_id: string; position_actuelle: unknown }
        Returns: {
          adresse: string
          code_postal: string
          nom: string
          ville: string
        }[]
      }
      set_geolocation_choice: {
        Args: {
          autorise: boolean
          p_code: string
          p_version: string
          precise: boolean
        }
        Returns: undefined
      }
      set_primary_photo: { Args: { photo_id: string }; Returns: undefined }
      st_3dclosestpoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_3ddistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_3dintersects: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_3dlongestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_3dmakebox: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_3dmaxdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_3dshortestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_addpoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_angle:
        | { Args: { line1: unknown; line2: unknown }; Returns: number }
        | {
            Args: { pt1: unknown; pt2: unknown; pt3: unknown; pt4?: unknown }
            Returns: number
          }
      st_area:
        | { Args: { geog: unknown; use_spheroid?: boolean }; Returns: number }
        | { Args: { "": string }; Returns: number }
      st_asencodedpolyline: {
        Args: { geom: unknown; nprecision?: number }
        Returns: string
      }
      st_asewkt: { Args: { "": string }; Returns: string }
      st_asgeojson:
        | {
            Args: { geog: unknown; maxdecimaldigits?: number; options?: number }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; options?: number }
            Returns: string
          }
        | {
            Args: {
              geom_column?: string
              maxdecimaldigits?: number
              pretty_bool?: boolean
              r: Record<string, unknown>
            }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
      st_asgml:
        | {
            Args: {
              geog: unknown
              id?: string
              maxdecimaldigits?: number
              nprefix?: string
              options?: number
            }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; options?: number }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
        | {
            Args: {
              geog: unknown
              id?: string
              maxdecimaldigits?: number
              nprefix?: string
              options?: number
              version: number
            }
            Returns: string
          }
        | {
            Args: {
              geom: unknown
              id?: string
              maxdecimaldigits?: number
              nprefix?: string
              options?: number
              version: number
            }
            Returns: string
          }
      st_askml:
        | {
            Args: { geog: unknown; maxdecimaldigits?: number; nprefix?: string }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; nprefix?: string }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
      st_aslatlontext: {
        Args: { geom: unknown; tmpl?: string }
        Returns: string
      }
      st_asmarc21: { Args: { format?: string; geom: unknown }; Returns: string }
      st_asmvtgeom: {
        Args: {
          bounds: unknown
          buffer?: number
          clip_geom?: boolean
          extent?: number
          geom: unknown
        }
        Returns: unknown
      }
      st_assvg:
        | {
            Args: { geog: unknown; maxdecimaldigits?: number; rel?: number }
            Returns: string
          }
        | {
            Args: { geom: unknown; maxdecimaldigits?: number; rel?: number }
            Returns: string
          }
        | { Args: { "": string }; Returns: string }
      st_astext: { Args: { "": string }; Returns: string }
      st_astwkb:
        | {
            Args: {
              geom: unknown
              prec?: number
              prec_m?: number
              prec_z?: number
              with_boxes?: boolean
              with_sizes?: boolean
            }
            Returns: string
          }
        | {
            Args: {
              geom: unknown[]
              ids: number[]
              prec?: number
              prec_m?: number
              prec_z?: number
              with_boxes?: boolean
              with_sizes?: boolean
            }
            Returns: string
          }
      st_asx3d: {
        Args: { geom: unknown; maxdecimaldigits?: number; options?: number }
        Returns: string
      }
      st_azimuth:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: number }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: number }
      st_boundingdiagonal: {
        Args: { fits?: boolean; geom: unknown }
        Returns: unknown
      }
      st_buffer:
        | {
            Args: { geom: unknown; options?: string; radius: number }
            Returns: unknown
          }
        | {
            Args: { geom: unknown; quadsegs: number; radius: number }
            Returns: unknown
          }
      st_centroid: { Args: { "": string }; Returns: unknown }
      st_clipbybox2d: {
        Args: { box: unknown; geom: unknown }
        Returns: unknown
      }
      st_closestpoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_collect: { Args: { geom1: unknown; geom2: unknown }; Returns: unknown }
      st_concavehull: {
        Args: {
          param_allow_holes?: boolean
          param_geom: unknown
          param_pctconvex: number
        }
        Returns: unknown
      }
      st_contains: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_containsproperly: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_coorddim: { Args: { geometry: unknown }; Returns: number }
      st_coveredby:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_covers:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_crosses: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_curvetoline: {
        Args: { flags?: number; geom: unknown; tol?: number; toltype?: number }
        Returns: unknown
      }
      st_delaunaytriangles: {
        Args: { flags?: number; g1: unknown; tolerance?: number }
        Returns: unknown
      }
      st_difference: {
        Args: { geom1: unknown; geom2: unknown; gridsize?: number }
        Returns: unknown
      }
      st_disjoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_distance:
        | {
            Args: { geog1: unknown; geog2: unknown; use_spheroid?: boolean }
            Returns: number
          }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: number }
      st_distancesphere:
        | { Args: { geom1: unknown; geom2: unknown }; Returns: number }
        | {
            Args: { geom1: unknown; geom2: unknown; radius: number }
            Returns: number
          }
      st_distancespheroid: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_dwithin: {
        Args: {
          geog1: unknown
          geog2: unknown
          tolerance: number
          use_spheroid?: boolean
        }
        Returns: boolean
      }
      st_equals: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_expand:
        | { Args: { box: unknown; dx: number; dy: number }; Returns: unknown }
        | {
            Args: { box: unknown; dx: number; dy: number; dz?: number }
            Returns: unknown
          }
        | {
            Args: {
              dm?: number
              dx: number
              dy: number
              dz?: number
              geom: unknown
            }
            Returns: unknown
          }
      st_force3d: { Args: { geom: unknown; zvalue?: number }; Returns: unknown }
      st_force3dm: {
        Args: { geom: unknown; mvalue?: number }
        Returns: unknown
      }
      st_force3dz: {
        Args: { geom: unknown; zvalue?: number }
        Returns: unknown
      }
      st_force4d: {
        Args: { geom: unknown; mvalue?: number; zvalue?: number }
        Returns: unknown
      }
      st_generatepoints:
        | { Args: { area: unknown; npoints: number }; Returns: unknown }
        | {
            Args: { area: unknown; npoints: number; seed: number }
            Returns: unknown
          }
      st_geogfromtext: { Args: { "": string }; Returns: unknown }
      st_geographyfromtext: { Args: { "": string }; Returns: unknown }
      st_geohash:
        | { Args: { geog: unknown; maxchars?: number }; Returns: string }
        | { Args: { geom: unknown; maxchars?: number }; Returns: string }
      st_geomcollfromtext: { Args: { "": string }; Returns: unknown }
      st_geometricmedian: {
        Args: {
          fail_if_not_converged?: boolean
          g: unknown
          max_iter?: number
          tolerance?: number
        }
        Returns: unknown
      }
      st_geometryfromtext: { Args: { "": string }; Returns: unknown }
      st_geomfromewkt: { Args: { "": string }; Returns: unknown }
      st_geomfromgeojson:
        | { Args: { "": Json }; Returns: unknown }
        | { Args: { "": Json }; Returns: unknown }
        | { Args: { "": string }; Returns: unknown }
      st_geomfromgml: { Args: { "": string }; Returns: unknown }
      st_geomfromkml: { Args: { "": string }; Returns: unknown }
      st_geomfrommarc21: { Args: { marc21xml: string }; Returns: unknown }
      st_geomfromtext: { Args: { "": string }; Returns: unknown }
      st_gmltosql: { Args: { "": string }; Returns: unknown }
      st_hasarc: { Args: { geometry: unknown }; Returns: boolean }
      st_hausdorffdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_hexagon: {
        Args: { cell_i: number; cell_j: number; origin?: unknown; size: number }
        Returns: unknown
      }
      st_hexagongrid: {
        Args: { bounds: unknown; size: number }
        Returns: Record<string, unknown>[]
      }
      st_interpolatepoint: {
        Args: { line: unknown; point: unknown }
        Returns: number
      }
      st_intersection: {
        Args: { geom1: unknown; geom2: unknown; gridsize?: number }
        Returns: unknown
      }
      st_intersects:
        | { Args: { geog1: unknown; geog2: unknown }; Returns: boolean }
        | { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_isvaliddetail: {
        Args: { flags?: number; geom: unknown }
        Returns: Database["public"]["CompositeTypes"]["valid_detail"]
        SetofOptions: {
          from: "*"
          to: "valid_detail"
          isOneToOne: true
          isSetofReturn: false
        }
      }
      st_length:
        | { Args: { geog: unknown; use_spheroid?: boolean }; Returns: number }
        | { Args: { "": string }; Returns: number }
      st_letters: { Args: { font?: Json; letters: string }; Returns: unknown }
      st_linecrossingdirection: {
        Args: { line1: unknown; line2: unknown }
        Returns: number
      }
      st_linefromencodedpolyline: {
        Args: { nprecision?: number; txtin: string }
        Returns: unknown
      }
      st_linefromtext: { Args: { "": string }; Returns: unknown }
      st_linelocatepoint: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_linetocurve: { Args: { geometry: unknown }; Returns: unknown }
      st_locatealong: {
        Args: { geometry: unknown; leftrightoffset?: number; measure: number }
        Returns: unknown
      }
      st_locatebetween: {
        Args: {
          frommeasure: number
          geometry: unknown
          leftrightoffset?: number
          tomeasure: number
        }
        Returns: unknown
      }
      st_locatebetweenelevations: {
        Args: { fromelevation: number; geometry: unknown; toelevation: number }
        Returns: unknown
      }
      st_longestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_makebox2d: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_makeline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_makevalid: {
        Args: { geom: unknown; params: string }
        Returns: unknown
      }
      st_maxdistance: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: number
      }
      st_minimumboundingcircle: {
        Args: { inputgeom: unknown; segs_per_quarter?: number }
        Returns: unknown
      }
      st_mlinefromtext: { Args: { "": string }; Returns: unknown }
      st_mpointfromtext: { Args: { "": string }; Returns: unknown }
      st_mpolyfromtext: { Args: { "": string }; Returns: unknown }
      st_multilinestringfromtext: { Args: { "": string }; Returns: unknown }
      st_multipointfromtext: { Args: { "": string }; Returns: unknown }
      st_multipolygonfromtext: { Args: { "": string }; Returns: unknown }
      st_node: { Args: { g: unknown }; Returns: unknown }
      st_normalize: { Args: { geom: unknown }; Returns: unknown }
      st_offsetcurve: {
        Args: { distance: number; line: unknown; params?: string }
        Returns: unknown
      }
      st_orderingequals: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_overlaps: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: boolean
      }
      st_perimeter: {
        Args: { geog: unknown; use_spheroid?: boolean }
        Returns: number
      }
      st_pointfromtext: { Args: { "": string }; Returns: unknown }
      st_pointm: {
        Args: {
          mcoordinate: number
          srid?: number
          xcoordinate: number
          ycoordinate: number
        }
        Returns: unknown
      }
      st_pointz: {
        Args: {
          srid?: number
          xcoordinate: number
          ycoordinate: number
          zcoordinate: number
        }
        Returns: unknown
      }
      st_pointzm: {
        Args: {
          mcoordinate: number
          srid?: number
          xcoordinate: number
          ycoordinate: number
          zcoordinate: number
        }
        Returns: unknown
      }
      st_polyfromtext: { Args: { "": string }; Returns: unknown }
      st_polygonfromtext: { Args: { "": string }; Returns: unknown }
      st_project: {
        Args: { azimuth: number; distance: number; geog: unknown }
        Returns: unknown
      }
      st_quantizecoordinates: {
        Args: {
          g: unknown
          prec_m?: number
          prec_x: number
          prec_y?: number
          prec_z?: number
        }
        Returns: unknown
      }
      st_reduceprecision: {
        Args: { geom: unknown; gridsize: number }
        Returns: unknown
      }
      st_relate: { Args: { geom1: unknown; geom2: unknown }; Returns: string }
      st_removerepeatedpoints: {
        Args: { geom: unknown; tolerance?: number }
        Returns: unknown
      }
      st_segmentize: {
        Args: { geog: unknown; max_segment_length: number }
        Returns: unknown
      }
      st_setsrid:
        | { Args: { geog: unknown; srid: number }; Returns: unknown }
        | { Args: { geom: unknown; srid: number }; Returns: unknown }
      st_sharedpaths: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_shortestline: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_simplifypolygonhull: {
        Args: { geom: unknown; is_outer?: boolean; vertex_fraction: number }
        Returns: unknown
      }
      st_split: { Args: { geom1: unknown; geom2: unknown }; Returns: unknown }
      st_square: {
        Args: { cell_i: number; cell_j: number; origin?: unknown; size: number }
        Returns: unknown
      }
      st_squaregrid: {
        Args: { bounds: unknown; size: number }
        Returns: Record<string, unknown>[]
      }
      st_srid:
        | { Args: { geog: unknown }; Returns: number }
        | { Args: { geom: unknown }; Returns: number }
      st_subdivide: {
        Args: { geom: unknown; gridsize?: number; maxvertices?: number }
        Returns: unknown[]
      }
      st_swapordinates: {
        Args: { geom: unknown; ords: unknown }
        Returns: unknown
      }
      st_symdifference: {
        Args: { geom1: unknown; geom2: unknown; gridsize?: number }
        Returns: unknown
      }
      st_symmetricdifference: {
        Args: { geom1: unknown; geom2: unknown }
        Returns: unknown
      }
      st_tileenvelope: {
        Args: {
          bounds?: unknown
          margin?: number
          x: number
          y: number
          zoom: number
        }
        Returns: unknown
      }
      st_touches: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_transform:
        | {
            Args: { from_proj: string; geom: unknown; to_proj: string }
            Returns: unknown
          }
        | {
            Args: { from_proj: string; geom: unknown; to_srid: number }
            Returns: unknown
          }
        | { Args: { geom: unknown; to_proj: string }; Returns: unknown }
      st_triangulatepolygon: { Args: { g1: unknown }; Returns: unknown }
      st_union:
        | { Args: { geom1: unknown; geom2: unknown }; Returns: unknown }
        | {
            Args: { geom1: unknown; geom2: unknown; gridsize: number }
            Returns: unknown
          }
      st_voronoilines: {
        Args: { extend_to?: unknown; g1: unknown; tolerance?: number }
        Returns: unknown
      }
      st_voronoipolygons: {
        Args: { extend_to?: unknown; g1: unknown; tolerance?: number }
        Returns: unknown
      }
      st_within: { Args: { geom1: unknown; geom2: unknown }; Returns: boolean }
      st_wkbtosql: { Args: { wkb: string }; Returns: unknown }
      st_wkttosql: { Args: { "": string }; Returns: unknown }
      st_wrapx: {
        Args: { geom: unknown; move: number; wrap: number }
        Returns: unknown
      }
      submit_answer: { Args: { idx: number[]; k: string }; Returns: undefined }
      unaccent: { Args: { "": string }; Returns: string }
      unlockrows: { Args: { "": string }; Returns: number }
      updategeometrysrid: {
        Args: {
          catalogn_name: string
          column_name: string
          new_srid_in: number
          schema_name: string
          table_name: string
        }
        Returns: string
      }
      user_activation_checklist: {
        Args: never
        Returns: {
          condition: string
          rang: number
          satisfaite: boolean
        }[]
      }
      user_progress: {
        Args: never
        Returns: {
          compte_actif: boolean
          etape_courante: number
          etapes_total: number
          secondes_restantes: number
        }[]
      }
      verify_account_code: { Args: { code: string }; Returns: boolean }
      verify_postal_code: { Args: { code: string }; Returns: boolean }
      visible_priorities: {
        Args: never
        Returns: {
          pair_key: string
          phrase: string
          rang: number
          verrouille: boolean
        }[]
      }
    }
    Enums: {
      collection_moment: "onboarding" | "quiz" | "backend"
      criterion_direction: "self" | "pref"
      date_status:
        | "en_preparation"
        | "confirme"
        | "en_cours"
        | "termine"
        | "annule"
      match_type: "aligne" | "mapping" | "importance" | "repoussoir" | "echelle"
      moderation_status: "en_attente" | "approuvee" | "rejetee"
      partner_status:
        | "brouillon"
        | "en_verification"
        | "rejete"
        | "actif"
        | "suspendu"
      photo_source: "google_reference" | "import_partenaire"
      report_reason:
        | "faux_profil"
        | "harcelement"
        | "contenu_sexuel"
        | "mineur"
        | "violence"
        | "arnaque"
        | "comportement_rendez_vous"
        | "autre"
      report_status: "nouveau" | "en_cours" | "traite" | "rejete"
      score_group: "physique" | "valeurs" | "mode_vie"
      sensitive_category:
        | "origine_ethnique"
        | "convictions_religieuses"
        | "opinions_politiques"
        | "orientation_sexuelle"
        | "sante"
        | "biometrie"
        | "geolocalisation"
        | "identite_genre"
      unit_system: "metrique" | "imperial"
      verif_channel: "email" | "sms"
      verification_status: "en_attente" | "validee" | "refusee" | "expiree"
    }
    CompositeTypes: {
      geometry_dump: {
        path: number[] | null
        geom: unknown
      }
      valid_detail: {
        valid: boolean | null
        reason: string | null
        location: unknown
      }
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      collection_moment: ["onboarding", "quiz", "backend"],
      criterion_direction: ["self", "pref"],
      date_status: [
        "en_preparation",
        "confirme",
        "en_cours",
        "termine",
        "annule",
      ],
      match_type: ["aligne", "mapping", "importance", "repoussoir", "echelle"],
      moderation_status: ["en_attente", "approuvee", "rejetee"],
      partner_status: [
        "brouillon",
        "en_verification",
        "rejete",
        "actif",
        "suspendu",
      ],
      photo_source: ["google_reference", "import_partenaire"],
      report_reason: [
        "faux_profil",
        "harcelement",
        "contenu_sexuel",
        "mineur",
        "violence",
        "arnaque",
        "comportement_rendez_vous",
        "autre",
      ],
      report_status: ["nouveau", "en_cours", "traite", "rejete"],
      score_group: ["physique", "valeurs", "mode_vie"],
      sensitive_category: [
        "origine_ethnique",
        "convictions_religieuses",
        "opinions_politiques",
        "orientation_sexuelle",
        "sante",
        "biometrie",
        "geolocalisation",
        "identite_genre",
      ],
      unit_system: ["metrique", "imperial"],
      verif_channel: ["email", "sms"],
      verification_status: ["en_attente", "validee", "refusee", "expiree"],
    },
  },
} as const
