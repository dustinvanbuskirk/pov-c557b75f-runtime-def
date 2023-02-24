# Set Arguments

while getopts i:g:r:d: flag
do
    case "${flag}" in
        i) image_list=${OPTARG};;
        g) git_repository=${OPTARG};;
        r) docker_registry=${OPTARG};;
        d) dryrun=${OPTARG};;
    esac
done
echo "Image List File: $image_list";
echo "Target Repository: $docker_registry";

while IFS="" read -r p || [ -n "$p" ]
do
  if [[ "$p" == *\/* ]] 
  then
    n=$(echo $p | sed "s:^[^/]*/:$docker_registry/:") 
  else
    n="$docker_registry/$p"
  fi
  printf '%s\n' "$p"' ---> '"$n"
  if [[ "$dryrun" == "" ]] 
  then
    docker pull --platform=linux/amd64 $p 
    docker tag $p $n
    docker push $n
  fi
done < $image_list

IFS=$'\n'
runtime_file=./manifests/runtime.yaml
if [[ "$dryrun" == "" ]]
then
  printf 'Applying Manifest Changes'
  echo 'Manifest Updates' > manifest_updates.log
  for f in `grep -rl custom_registry ./manifests`
  do
    printf "Updating $f with $docker_registry\n"
    echo '==========================================================' >> manifest_updates.log
    echo "Original $f" >> manifest_updates.log
    echo '==========================================================' >> manifest_updates.log
    cat $f >> manifest_updates.log
    echo '==========================================================' >> manifest_updates.log
    echo "New $f" >> manifest_updates.log
    echo '==========================================================' >> manifest_updates.log
    sed -i .bak "s:custom_registry:$docker_registry:g" $f
    cat $f >> manifest_updates.log
  done
  printf 'Applying runtime.yaml changes.\n'
  echo '==========================================================' >> manifest_updates.log
  echo "Original $runtime_file" >> manifest_updates.log
  echo '==========================================================' >> manifest_updates.log
  cat $runtime_file >> manifest_updates.log
  echo '==========================================================' >> manifest_updates.log
  echo "New $runtime_file" >> manifest_updates.log
  echo '==========================================================' >> manifest_updates.log
  sed -i .bak "s:git_org/git_repo:$git_repository:g" $runtime_file
  cat $runtime_file >> manifest_updates.log
  printf 'See manifest_updates.log for details.'
else
  printf 'Starting dryrun\n'
  echo 'Start Dry Run of Manifest Updates >>>' > manifest_dryrun.log
  for f in `grep -rl custom_registry ./manifests`
  do
    printf "Updating $f with $docker_registry\n"
    echo '==========================================================' >> manifest_dryrun.log
    echo "Original $f" >> manifest_dryrun.log
    echo '==========================================================' >> manifest_dryrun.log
    cat $f >> manifest_dryrun.log
    echo '==========================================================' >> manifest_dryrun.log
    echo "New $f" >> manifest_dryrun.log
    echo '==========================================================' >> manifest_dryrun.log
    sed "s:custom_registry:$docker_registry:g" $f >> manifest_dryrun.log
  done
  printf 'Applying runtime.yaml changes.\n'
  echo '==========================================================' >> manifest_dryrun.log
  echo "Original $runtime_file" >> manifest_dryrun.log
  echo '==========================================================' >> manifest_dryrun.log
  cat $runtime_file >> manifest_dryrun.log
  echo '==========================================================' >> manifest_dryrun.log
  echo "New $runtime_file" >> manifest_dryrun.log
  echo '==========================================================' >> manifest_dryrun.log
  sed "s:git_org/git_repo:$git_repository:g" $runtime_file >> manifest_dryrun.log
  printf 'See manifest_dryrun.log for details.'
fi