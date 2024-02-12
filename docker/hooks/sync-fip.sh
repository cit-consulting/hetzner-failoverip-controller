#!/usr/bin/env bash

source common/process-resource.sh

if [[ $1 == "--config" ]] ; then
  mkdir "${TMPDIR%/}/fip"
  cat sync-fip.config.json
else
  type=$(jq -r '.[0].type' "${BINDING_CONTEXT_PATH}")

  if [[ "$type" == "Event" ]] ; then
    resourceName=$(jq -r '.[0].object.metadata.name' "${BINDING_CONTEXT_PATH}")
    echo "Processing resource ${resourceName} on event"
    failoverIpCommand=$(jq -r '.[0].object.spec.getFailoverIpCommand' "${BINDING_CONTEXT_PATH}")
    targetServerIp=$(jq -r '.[0].object.spec.getTargetServerMainIpCommand' "${BINDING_CONTEXT_PATH}")
    dryRun=$(jq -r '.[0].object.spec.dryRun' ${BINDING_CONTEXT_PATH})
    process_resource "$failoverIpCommand" "$targetServerIp" "$dryRun" "$resourceName"
  fi

  if [[ "$type" == "Schedule" ]] ; then
    countResourceOnSchedule=$(jq -r '.[0].snapshots["failoverip-policy"] | length' "${BINDING_CONTEXT_PATH}")
    echo "Processing ${countResourceOnSchedule} resources on schedule"
    for ((i=0;i<countResourceOnSchedule;i++)); do
      resourceName=$(jq -r '.[0].snapshots["failoverip-policy"].['$i'].object.metadata.name' "${BINDING_CONTEXT_PATH}")
      failoverIpCommand=$(jq -r '.[0].snapshots["failoverip-policy"].['$i'].object.spec.getFailoverIpCommand' "${BINDING_CONTEXT_PATH}")
      targetServerIp=$(jq -r '.[0].snapshots["failoverip-policy"].['$i'].object.spec.getTargetServerMainIpCommand' "${BINDING_CONTEXT_PATH}")
      dryRun=$(jq -r '.[0].snapshots["failoverip-policy"].['$i'].object.spec.dryRun' "${BINDING_CONTEXT_PATH}")
      process_resource "$failoverIpCommand" "$targetServerIp" "$dryRun" "$resourceName"
    done
  fi

  rm -f "${TMPDIR%/}"/fip/*

fi

exit 0
