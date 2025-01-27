
#!/bin/bash

set_cluster() {
    gcloud container clusters get-credentials --project $DEVCMD_GCP_PROJECT_ID $1 --zone $2
}

case $1 in
   dev)
      set_cluster $1 europe-north1-b
      ;;
   stage)
      set_cluster fcc-$1 europe-north1-a
      ;;
   prod)
      set_cluster fcc-$1 europe-north1-a
      ;;
   "")
      kubectl config current-context
      ;;
   *)
      echo Invalid env $1
     ;;
esac
