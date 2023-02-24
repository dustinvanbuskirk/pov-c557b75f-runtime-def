# Set Arguments

while getopts i:r:d: flag
do
    case "${flag}" in
        i) image_list=${OPTARG};;
        r) repository=${OPTARG};;
        d) dryrun==${OPTARG};;
    esac
done
echo "Image List File: $image_list";
echo "Target Repository: $repository";

while IFS="" read -r p || [ -n "$p" ]
do
  if [[ "$p" == *\/* ]] 
  then
    n=$(echo $p | sed "s:^[^/]*/:$repository/:") 
  else
    n="$repository/$p"
  fi
  printf '%s\n' "$p"' ---> '"$n"
  if [[ "$dryrun" == "" ]] 
  then
    docker pull $p 
    docker tag $p $n
    docker push $n
  fi
done < $image_list

IFS=$'\n'
if [[ "$dryrun" == "" ]]
then
  printf 'Applying Manifest Changes'
  echo 'Manifest Updates' > manifest_updates.log
  for f in `grep -rl custom_registry ./manifests`
  do
    printf "Updating $f with $repository\n"
    echo '==========================================================' >> manifest_updates.log
    echo "Original $f" >> manifest_updates.log
    echo '==========================================================' >> manifest_updates.log
    cat $f >> manifest_updates.log
    echo '==========================================================' >> manifest_updates.log
    echo "New $f" >> manifest_updates.log
    echo '==========================================================' >> manifest_updates.log
    sed -i .bak "s:custom_registry:$repository:g" $f >> manifest_updates.log
  done
  printf 'See manifest_updates.log for details.'
else
  printf 'Starting dryrun\n'
  echo 'Start Dry Run of Manifest Updates >>>' > manifest_dryrun.log
  for f in `grep -rl custom_registry ./manifests`
  do
    printf "Updating $f with $repository\n"
    echo '==========================================================' >> manifest_dryrun.log
    echo "Original $f" >> manifest_dryrun.log
    echo '==========================================================' >> manifest_dryrun.log
    cat $f >> manifest_dryrun.log
    echo '==========================================================' >> manifest_dryrun.log
    echo "New $f" >> manifest_dryrun.log
    echo '==========================================================' >> manifest_dryrun.log
    sed "s:custom_registry:$repository:g" $f >> manifest_dryrun.log
  done
  printf 'See manifest_dryrun.log for details.'
fi