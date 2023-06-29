# akamai-opensearch
Implementation of opensearch to test Akamai DataStream and Akamai SIEM Connector

## 1. Introduction

The project intends to provide a easy way to setup opensearch project (https://opensearch.org/) to integrate with Akamai products like SIEM integration and DataStream.

## 2. Motivation

Customers want to use Openseach, analyze and process their Akamai Security Data, DataStream Data to build reports, dashboards or even to get insights in real-time to take actions in a fast manner.

## 3. Maintainers

- [Leandro Cassiano](https://contacts.akamai.com/lcassian) - Solution Architect LATAM
- [Felipe Vilarinho](https://contacts.akamai.com/fvilarin) - Engagement Manager LATAM

## 4. Configure

Clone last version of repository.
- `git clone https://github.com/lcassiano/akamai-opensearch.git` 
Edit file  iac/1-apply-variables.sh and change e-mail to valid e-mail
- `nano akamai-opensearch/iac/1-apply-variables.sh`
- `export APPEMAIL=example@example.com`

## 5. How to install

After the provisioning finished, execute the following commands:

- `bash akamai-opensearch/k3s_setup.sh`
- `cd akamai-opensearch/iac/`
- `bash setup.sh install`
- `bash setup.sh start`