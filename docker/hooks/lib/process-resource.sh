run_timestamp=$(date +%s)

function process_resource() {
  failoverIpCommand="$1"
  targetServerIpCommand="$2"
  dryRun="$3"
  resourceName="$4"
  echo "Processing resource $resourceName"
  failoverIp=$(bash -c "$failoverIpCommand")
  if [[ $? -ne 0 ]]; then
    echo "$1 failed for $resourceName"
    return 1
  else
    if [[ $failoverIp =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Got failover IP $failoverIp for $resourceName"
    else
      echo "$failoverIpCommand returns invalid id $failoverIp for $resourceName"
      return 2
    fi
  fi

  targetServerIp=$(bash -c "$targetServerIpCommand")
  if [[ $? -ne 0 ]]; then
    echo "$targetServerIpCommand failed for $resourceName"
    return 3
  else
    if [[ $targetServerIp  =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
      echo "Got target IP $targetServerIp for $resourceName"
    else
      echo "$targetServerIpCommand returns invalid target IP $targetServerIp for $resourceName"
      return 4
    fi
  fi

  if [ "$dryRun" = true ]; then
      echo "This is dry run - skip IP sync"
      return 0
  fi

  currentFailoverStateFile=${TMPDIR%/}/fip/$run_timestamp
  if [ -f "$currentFailoverStateFile" ]; then
      echo "Reuse failover state from $currentFailoverStateFile"
  else
    echo "Fetch actual failover state into $currentFailoverStateFile."
    curl -f -u "$ROBOT_API_USERNAME:$ROBOT_API_PASSWORD" https://robot-ws.your-server.de/failover > "$currentFailoverStateFile"
    if [[ $? -ne 0 ]]; then
      echo "FATAL: unable to fetch current failover state from Robot API."
      exit 1
    fi
  fi
  currentFailoverTarget=$(jq -r ".[] | select(.failover.ip==\"${failoverIp}\").failover.active_server_ip" "$currentFailoverStateFile")
  rm "$currentFailoverStateFile"
  echo "$currentFailoverTarget"
  if [ -z "$currentFailoverTarget" ]; then
      echo "Failover IP $failoverIp not available on current account"
      return 5
  elif [ "$currentFailoverTarget" = "$targetServerIp" ]; then
      echo "Failover IP $failoverIp already routed to configured target $targetServerIp"
      return 0
  else
    echo "Failover IP $failoverIp needs to be routed to $targetServerIp instead of current $currentFailoverTarget"
  fi

  curl -f -u "$ROBOT_API_USERNAME:$ROBOT_API_PASSWORD" https://robot-ws.your-server.de/failover/"$failoverIp" -d active_server_ip="$targetServerIp"
  if [[ $? -ne 0 ]]; then
    echo "Resource $resourceName processing failed"
  else
    echo "Resource $resourceName processed"
  fi
}
