function create_compose --description "Create compose.yaml for docker compose v2" --argument-names num image
  set --local container_name (pwd | sed "s/\/.*\///")
  if test -f Dockerfile
      set container_image "build: ."
  else if test $image
      set container_image "image: $image"
  else
      # default image
      set container_image "image: nvidia/cuda:11.0.3-cudnn8-devel-ubuntu20.04"
  end
  set --local body "
version: '3'
services:
  $container_name:
    $container_image
    command: /bin/bash
    tty: true
    container_name: $container_name
    working_dir: /app
    deploy:
      resources:
        reservations:
          devices:
          - driver: nvidia
            capabilities: [gpu]
    volumes:
      - ./:/app"

    echo $body > $PWD/compose.yaml
end

function __fish_print_docker_images --description 'Print a list of docker images'
    docker images --format "{{.Repository}}:{{.Tag}}" | command grep -v '<none>'
end 

complete -c create_compose -f
complete -c create_compose -f -s i -l image -xa '(__fish_print_docker_images)' -d "Image"

