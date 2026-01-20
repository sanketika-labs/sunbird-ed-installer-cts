#!/usr/bin/env bash
set -euo pipefail

RELEASE="${1:-obsrvbb}"
NAMESPACE="${2:-sunbird}"
LABEL="app.kubernetes.io/instance=${RELEASE}"

ts() { date +"%Y-%m-%dT%H:%M:%S%z"; }
log() { echo "$(ts) :: $*"; }

log "Starting cleanup for release='${RELEASE}' namespace='${NAMESPACE}'"

log "[1/7] Helm uninstall check"
if helm status "${RELEASE}" -n "${NAMESPACE}" >/dev/null 2>&1; then
  log "Helm release found; uninstalling"
  helm uninstall "${RELEASE}" -n "${NAMESPACE}"
  log "Helm uninstall finished"
else
  log "Helm release not found; continuing with manual cleanup"
fi

log "[2/7] Deleting namespaced core resources (pods, svc, rs, deploy, etc.)"
kubectl delete all -n "${NAMESPACE}" -l "${LABEL}" --ignore-not-found

log "[3/7] Deleting other namespaced resources (jobs, cronjobs, pvc, cm, secret, sa, rbac, pdb, hpa)"
kubectl delete job,cronjob,pvc,configmap,secret,serviceaccount,role,rolebinding,pdb,hpa -n "${NAMESPACE}" -l "${LABEL}" --ignore-not-found

log "[4/7] Deleting cluster-scoped RBAC with label ${LABEL}"
kubectl delete clusterrole,clusterrolebinding -l "${LABEL}" --ignore-not-found

log "[5/7] Deleting Druid resources (CRs, Deployments, and StatefulSets)"
log "  - Deleting Druid CRs"
kubectl delete druid.druid.apache.org -A --ignore-not-found || true
log "  - Deleting Druid-managed deployments and statefulsets by label"
kubectl delete deployment,statefulset -n "${NAMESPACE}" -l "app=druid" --ignore-not-found || true
kubectl delete deployment,statefulset -n "${NAMESPACE}" -l "druid_cr=raw" --ignore-not-found || true
log "  - Deleting Druid CRD"
kubectl delete crd druids.druid.apache.org --ignore-not-found || true

log "[6/7] Deleting PVs and PVCs (including secor, druid)"
log "  - Deleting PVCs by pattern in namespace ${NAMESPACE}"
kubectl delete pvc -n "${NAMESPACE}" -l "${LABEL}" --ignore-not-found
kubectl delete pvc -n "${NAMESPACE}" -l "app=secor" --ignore-not-found || true
kubectl delete pvc -n "${NAMESPACE}" -l "app=druid" --ignore-not-found || true

log "Obsrvbb Cleanup finished"
