---
title: Changelog
description: Release history and notable changes for AnyLog deployment scripts.
layout: page
---

## Unreleased
<!-- last-processed: 9ea0519 -->

<!-- Developers: add bullets below as changes land in your branch -->

---
## 2.1.2611 (November 2026 · 9ea0519 · 2026-11-27)

### ✨ New Features
- **Barbara support**: deployment supports the new Barbara params, with a working Barbara example
- **DNS support**: nodes can be deployed using DNS names
- **`FORCE_DISABLE_ALL`**: when set, disables everything beyond the configs required for the specified node type
- **Automated MCP**: MCP is set up automatically so the connection is made from the Claude side. MCP now runs on the system query node by default; configure it manually for other uses
- **Unified license and status script**: license key handling and node status validation moved out of the policy into one script
- **Blockchain seed for non-master nodes**, and removed where it isn't needed
- **`monitoring_scheduler_env_params`**: new param for variables that repeat across monitoring schedules
- **Sample data**: weather station sample scripts (Customers and Data generator), wind turbine 2 test data, and basic random data with a hard-coded value for scale testing

### 🔄 Changes
- Customer scripts use `auto_uns = true` instead of `dynamic = true`
- Node name and cluster name logic reworked
- When `!create_policy == true`, the manual blockchain sync is skipped
- When `!tcp_bind == false` and `!policy_tcp_bind == false`, the external IP is checked as well
- Ledger connection logic is enforced
- Config publisher is commented out

### 🐛 Bug Fixes
- Node monitoring: `query` was parsed as a command, so it is now defined as a variable
- Fixed handling of overlay vs. no overlay
- Fixed missing params, a path issue, and order of operations in node deployment
- Fixed an `if` that should have been `else if` in the data generator, and missing weather data
- Monitoring prints a warning instead of an error where the issue isn't fatal

### ⚙️ Infrastructure & DevOps
- Version bumped to 2.1.2611
- Version control and changelog updates

---

## 2.1.2610 (October 2026 · 2e24415 · 2026-10-30)

### ✨ New Features
- **Zero-touch node naming**: nodes get generic names automatically, operator naming is smarter, `is_primary` is set automatically, and clusters and operators are numbered from the existing policy count. The company name comes from the license key when not set manually, and a pre-defined ID can be supplied
- **Config policies**: a node can be linked to a config policy (config/node relation), config info is stored on the node policy, and the deployment uses a config policy ID when one is given
- **Node monitoring by default**: node monitoring is now on unless explicitly disabled; storage and forwarding work as before. Monitoring policies are pre-created, monitoring runs on scheduler 2, and node types other than operator, publisher or generic skip it
- **Database options**: new `almgm` database type and `disable_ha` option, an option to disable partitions, and working PostgreSQL and SQLite setups. `system_query` is integrated with query nodes, and remote-GUI query nodes are identified as such
- **Networking**: new VPN advertise flag; node policies can use the local IP when the network is not bound; self-IP loopback in `set_params.al`; correct `127.0.0.1` ledger connections across different ports; broker configs
- **Orchestrator support** in node deployment
- **`SCRIPT_DEBUG`**: when enabled, turns on `set debug on` in every script file
- **Southbound / Industrial**: Sparkplug B examples using mapping, dynamic topic (`dynamic = true`) examples, a DNP3 example, and license key support
- **Customers**: Schneider weather station use case and a Dados script
- **Data generator**: vessel data, ProveIt data and MQTT calls. ProveIt MQTT topics now use a `proveit/` prefix, and the `vessel-data` topic is renamed `vessel-data-agg`
- **Sample scripts**: row count per node, notifications for all tables in the network (including water and waste water plants), relative-to-actual tag mapping, and a message when no data is found

### 🐛 Bug Fixes
- **Policies**
  - Fixed duplicate policies: the orchestrator policy no longer duplicates, and the hostname is no longer part of the policy
  - Fixed policy validation for overlay and TCP bindings; the node name is now validated along with network configs
  - Fixed an `else if` bug that overwrote the node name, a node policy cluster issue, and policy configs for a first operator on a second cluster
  - Fixed default ledger selection and a missing `!` in policy configs
  - Re-added exit scripts to fix a bug
- **Database**: fixed the AnyLog database not being created, and a sync bug
- **Monitoring**
  - Fixed repeated values in monitoring
  - Fixed the `schedule` parameter not being written correctly, a missing comma in `store_monitoring_dest`, a duplicate command, an `if`/`else` bug, and the scheduler setup
  - Monitoring now uses IP instead of hostname
- **Other**
  - Fixed IP issues in node deployment and a wrong Docker path
  - Fixed power plant MQTT and Sparkplug bugs, and missing variables in the water plant
  - Fixed the location of the `master_node` param for dynamic topics

### 🔧 Improvements
- Faster deployment: sleeps removed, blockchain sync runs at the end with a wait in every case, and cluster/operator sync was reworked
- Simplified cluster logic, license process, self lookup and node naming
- Archive node name validation and removal of duplicate code
- Hard-coded MQTT values removed
- Renamed `default_dbms` → `msg_dbms` and `run schedule` → `schedule`
- Simplified notifications

### ⚙️ Infrastructure & DevOps
- Image build tag naming, with an option to hide the tag
- Removed unneeded code across Archive, Customers, Data generator and Test
- Version bump

---

## 2026

### [bf794d5] · 2026-06-19 – 2026-06-23

| Date | Commit | Author | Summary |
|------|--------|--------|---------|
| 2026-06-22 | — | Ori Shadmon | Removed customer- and Ori-specific files (Archive, Customers, Test) |
| 2026-06-22 | — | Ori Shadmon | Smart city data generator reorg — improved MQTT logic, notifications, node monitoring + param configs |
| 2026-06-22 | — | Ori Shadmon | Node deployment — zero-touch support, node/cluster naming rework, monitoring policy integration |
| 2026-06-22 | — | Ori Shadmon | Node deployment / Database — operator helpers, monitoring DB creation, PSQL support |
| 2026-06-22 | — | Ori Shadmon | Node deployment / Policies — cluster numbering and naming fixes, monitoring policy simplification |
| 2026-06-22 | — | Ori Shadmon | Southbound / Industrial — Modbus mapping logic |
| 2026-06-22 | — | Ori Shadmon | Southbound / Monitoring — node monitoring, zero-touch support, syslog and Docker monitoring |
| 2026-06-22 | — | Ori Shadmon | Docker — working docker builder |
| 2026-06-22 | — | Ori Shadmon | General — file naming, image builder command, versioning, changelog cleanup |
| 2026-06-19 | — | pintomax | Sample scripts — fixed waste plan notifications |

---

### [4f8345a] · 2026-04-29

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