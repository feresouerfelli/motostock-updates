-- ══════════════════════════════════════════════════════════════
-- MotoStock Pro — Script d'initialisation WampServer MySQL
-- À exécuter dans phpMyAdmin (WampServer)
-- Ce script crée la base de données et les tables miroirs
-- identiques à l'application desktop (Drift SQLite)
-- ══════════════════════════════════════════════════════════════

CREATE DATABASE IF NOT EXISTS motostock
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE motostock;

-- ── Table des Fournisseurs ────────────────────────────────────
CREATE TABLE IF NOT EXISTS fournisseurs (
  id                    INT AUTO_INCREMENT PRIMARY KEY,
  nom                   VARCHAR(255) NOT NULL,
  contact               VARCHAR(255),
  telephone             VARCHAR(50),
  email                 VARCHAR(255),
  adresse               TEXT,
  delai_livraison_moyen INT DEFAULT 0,
  conditions_paiement   VARCHAR(255),
  created_at            DATETIME DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ── Table des Pièces (Stock) ──────────────────────────────────
CREATE TABLE IF NOT EXISTS pieces (
  id                    INT AUTO_INCREMENT PRIMARY KEY,
  reference             VARCHAR(100) NOT NULL UNIQUE,
  nom                   VARCHAR(255) NOT NULL,
  description           TEXT,
  categorie             VARCHAR(100) NOT NULL,
  compatibilites_motos  TEXT,
  quantite_en_stock     INT NOT NULL DEFAULT 0,
  quantite_minimale     INT NOT NULL DEFAULT 5,
  prix_achat            DOUBLE NOT NULL DEFAULT 0,
  prix_vente            DOUBLE NOT NULL DEFAULT 0,
  image_path            VARCHAR(500),
  emplacement           VARCHAR(255),
  garantie_duree        INT NOT NULL DEFAULT 0,
  fournisseur_id        INT,
  date_last_maj         DATETIME,
  created_at            DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id) ON DELETE SET NULL
) ENGINE=InnoDB;

-- ── Table des Mouvements de Stock (Ventes & Achats) ───────────
CREATE TABLE IF NOT EXISTS mouvements_stock (
  id         INT AUTO_INCREMENT PRIMARY KEY,
  piece_id   INT NOT NULL,
  type       VARCHAR(20) NOT NULL COMMENT "'entree' (achat), 'sortie' (vente), 'ajustement'",
  quantite   INT NOT NULL DEFAULT 1,
  motif      TEXT,
  date       DATETIME DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (piece_id) REFERENCES pieces(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ── Table des Commandes d'approvisionnement ───────────────────
CREATE TABLE IF NOT EXISTS commandes (
  id             INT AUTO_INCREMENT PRIMARY KEY,
  fournisseur_id INT NOT NULL,
  date_creation  DATETIME DEFAULT CURRENT_TIMESTAMP,
  statut         VARCHAR(30) NOT NULL DEFAULT 'brouillon' COMMENT "'brouillon', 'envoyée', 'reçue'",
  notes          TEXT,
  FOREIGN KEY (fournisseur_id) REFERENCES fournisseurs(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ══════════════════════════════════════════════════════════════
-- Fin du script. Toutes les tables sont prêtes !
-- ══════════════════════════════════════════════════════════════
