# Mobile

This is the mobile app for the project.

## Getting Started

Copy the `.env.example` file to `.env` and fill in the necessary values.

You can now install the dependencies and run the app.

> [!IMPORTANT]  
> You may need to reverse proxy the port `5000` using `adb reverse tcp:5000 tcp:5000` and change the `API_URL` in the `.env` file to `http://localhost:5000` if you are using your phone instead of an emulator.

## Using docker (Android only)

If you prefer to use docker to run the app (for example Flutter has issues running on your machine), you can use the following steps.

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
- Open the command palette (`Ctrl` + `Shift` + `P`) and select `Dev Containers: Reopen in Container`
- Wait for everything to finish running, and then, in the `Run and Debug` panel, run the app
