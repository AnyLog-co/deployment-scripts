---
title: Changelog
description: Release history and notable changes for AnyLog deployment scripts.
layout: page
---

## Unreleased
<!-- last-processed: bf794d5 -->

<!-- os-dev: bf794d5 (2026-06-23) -->

* **Ori Shadmon** (2026-04-29 – 2026-06-22)
  * Archive: removed ori specific files
  * Customers: customer use casess; removed ori specific files
  * Customers / Machine builder: removed ori specific files
  * Customers / ProveIt: removed ori specific files
  * Customers / Smart city: removed ori specific files
  * Data generator: reorg smart city + updating notifications; bring= -> value=bring; improved MQTT logic to better support smart city data; config policy path updated; automatic processing for MQTT - enhanced; node monitoring + param configs; missing then/true; missing then; removed ori specific files
  * Docker: working docker builder; dockerfile wrong; docker
  * General: reorg smart city + updating notifications; file naming; working docker builder; image builder command; version #; pre-develop -> main; in progress look @ no configs; git version ID; git ID; Update setup.cfg; changelog + remove unneeded files
  * Node deployment: rm license from cluster name; minor changes to support zero-touch; default company name + blockchain operator for main logic; rewrote node naming; node deployment; config policy path updated; automatic processing for MQTT - enhanced; zero-touch support; update to support version for configs; improve logical support for missing node / cluster name using unique ids from keys; node monitroing logic updated to support monitoring policy; improve params; node monitoring + param configs; if/else logic for default ports - include msg broker for operator + publisher; tmp added set debug in policy
  * Node deployment / Database: improve params; helpers for operator - in progress; contains logical datbase; moved monitoring db creation + added support to use psql
  * Node deployment / Policies: cluster numbering; node name for hidden; resolve syntax bugs; missing node name at restart; syntax errors; debug cluster; cluster name; minor changes to support zero-touch; file naming; default company name + blockchain operator for main logic; tmp; rewrote node naming; cluster naming; config policy path updated; automatic processing for MQTT - enhanced; zero-touch support; improve logical support for missing node / cluster name using unique ids from keys; simplification of monitoring policies in order to better gurantee actual monitoring; license key if condition moved only into script; added calls into config policy script - master/query only support node monitoring (need to look again at docker /syslog logic for remote machines); moved monitoring db creation + added support to use psql; missing 	hen on line 62/63; tmp added set debug in policy; missing if statement
  * Sample scripts: reorg smart city + updating notifications; format issues for query; smart city monitorig
  * Southbound / Industrial: modbus mapping; mapping logic 'issue'; modbus base logic
  * Southbound / Monitoring: node monitoring; zero-touch support; docker monitoring; monitoring logic to support monitoring ID; node monitroing logic updated to support monitoring policy; syslog to support any ip / port; node monitoring + param configs; simplification of monitoring policies in order to better gurantee actual monitoring; msg broker connection is built into configs for publisher / operator || env param; moved monitoring db creation + added support to use psql
  * Test: removed ori specific files
* **pintomax** (2026-06-19)
  * Sample scripts: Put back false as expected value; Fix waste plan notifications

<!-- Developers: add bullets below as changes land in your branch -->

---

## 2026

### [4f8345a] · 2026-04-29 (latest)

| Date | Commit | Author | Summary |
|------|--------|--------|---------|
| 2026-04-29 | [4f8345a] | Ori Shadmon | Remove archive / customer logic |
| 2026-04-28 | [8d556c6] | Ori Shadmon | Validate MQTT logic works |
| 2026-04-28 | [e7cb791] | Ori Shadmon | Validate MQTT logic works (follow-up fix) |

---

### [fc2309d] · 2026-04-17 – 2026-04-18

| Date | Commit | Author | Summary |
|------|--------|--------|---------|
| 2026-04-18 | [fc2309d] | Ori Shadmon | Litmus single table |
| 2026-04-17 | [a0c1637] | Ori Shadmon | Litmus 2 tables (supported) |
| 2026-04-17 | [02731e3] | Ori Shadmon | Telegraf supported |

---

### [a73584e] · 2026-04-08 – 2026-04-10

| Date | Commit | Author | Summary |
|------|--------|--------|---------|
| 2026-04-10 | [6fc2530] | Ori Shadmon | Skip publish to remote master when `!master_configs=true` |
| 2026-04-10 | [5e1c1c1] | Ori Shadmon | Integration of version control + slight reorg in `.github` dir |
| 2026-04-10 | [5c1e40f] | Ori Shadmon | Integration of version control + slight reorg in `.github` dir (follow-up) |
| 2026-04-09 | [3d224e4] | Moshe       | Integrate aggregation example as part of vessel demo |
| 2026-04-09 | [d5bca98] | Moshe       | Bug fix |
| 2026-04-08 | [a73584e] | Ori Shadmon | Power plant data |

> **Note:** This release group supersedes the previous [a73584e] entry — that commit is now covered above.

---

## 2025

2025 was defined by **policy maturity, monitoring expansion, and networking improvements**. The blockchain policy system was significantly extended with cluster, license, and relay policy support. Monitoring scripts were expanded across southbound connectors. Syslog integration was refined. Networking and overlay configuration scripts were added for multi-node deployments. Docker-based deployment was introduced for scripts. A major reorg consolidated script paths and naming conventions.

| Date | Commit | Summary |
|------|--------|---------|
| 2025-12 | — | Publish workflow scripts; relay and networking configs added |
|         |   | Cluster policy support in node-deployment |
|         |   | Monitoring script refactors for southbound connectors |
| 2025-10 | [423e749] | Blobs folder / dbms based on param |
|          | [eb0a352] | `blobs_folder` addition |
|          | [9f9a665] | Rename: `branch` → `branch_name` |
|          | [07cf288] | Rename: `$BRANCH` → `$BRANCH_NAME` |
|          | [681e2ff] | Update `node_policy.al` |
|          | [f4d9f42] | Akave demo scripts |
|          | [ef12590] | Akave demo support additions |
| 2025-09 | — | Blockchain policy reorg; path and config cleanup |
|         |   | Syslog script updates and parameter fixes |
| 2025-06 | — | License key management scripts added |
|         |   | Docker deployment support added to scripts |
| 2025-01 | — | License key integration — initial scripts |
|         |   | Monitoring improvements for industrial southbound |

---

## 2024

2024 focused on **smart city, gRPC/KubeArmor integration, and policy tooling**. Smart city demo scripts (power plant, waste water, water plant) were built out under the `customers/` directory. KubeArmor gRPC connector scripts were added and debugged. Policy creation and blockchain sync scripts were improved. Syslog ingestion scripts were introduced. Generic deployment configs were extended, and a set of demo and training scripts was organized.

| Date | Commit | Summary |
|------|--------|---------|
| 2024-12 | — | Generic deployment configs expanded; policy debug scripts added |
|         |   | Monitoring scripts updated with source and params fixes |
| 2024-09 | — | Smart city customer scripts — Grafana dashboards for power plant, waste water, water plant |
|         |   | Syslog ingestion scripts added |
| 2024-06 | — | gRPC / KubeArmor connector scripts added and debugged |
|         |   | Policy tooling improved — company/name fields, healthcheck |
| 2024-01 | [dcd5f17] | Fix KubeArmor integration |
|         | [62c40f7] | Added company and name fields to policy |
|         | [5b2e2bc] | gRPC script initial commit |
|         | [0cf02bf] | KubeArmor healthcheck |

---

## 2023

The `deployment-scripts` repository was established in May 2023. Initial work focused on **repository organization, operator/publisher policy scripts, and EdgeX connector support**. Branch structure was defined, core script paths were laid out, and monitoring and deployment scripts were created for standard AnyLog node roles. License policy scripts were introduced. Training scripts and sample configurations were added to help onboard new users.

| Date | Commit | Summary |
|------|--------|---------|
| 2023-12 | — | License policy scripts; monitoring scripts for operator nodes |
|         |   | Training and sample script additions |
| 2023-09 | — | Deployment script reorg; policy and config path standardization |
|         |   | Master node deployment scripts added |
| 2023-06 | [2ac9aee] | EdgeX connector scripts — initial commit |
|         | [45315b0] | EdgeX code additions |
| 2023-05 | [1938fba] | Initial commit — branch structure and repo organization |
|         | [d4e0bc9] | Reorg of script directories |
|         | [44ef282] | Rename and path additions |

---

*For the full commit-level history, run `git log` or browse the repository on GitHub.*