# Mobile

This is the mobile app for the project.

## Getting Started

Copy the `.env.example` file to `.env` and fill in the necessary values.

You can now run the app.

## Using docker (android only)

### Prerequisites

- Plug your android phone to your computer
- Install the `Dev Containers` extension (VSCode)

### Add service

Add this service in the root `compose.override.yml` :

```yml
mobile:
    container_name: fd-mobile
    build:
        context: .
        dockerfile: ./docker/dev/mobile/Dockerfile
    ports:
        - 5037:5037
    privileged: true
    volumes:
        - ./mobile:/app
        - /dev/bus/usb:/dev/bus/usb
        - /var/run/docker.sock:/var/run/docker.sock
```

### Run app

- Open the `mobile` project folder
- Open the command palette (`ctrl` + `shift` + `p`) and select `Dev Containers: Reopen in Container`
- Wait for everything to finish running, and then, in the `Run and Debug` panel, run the app
