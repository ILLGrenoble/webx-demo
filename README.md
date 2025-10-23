# WebX Demo

## Description

This project is used to build a Docker image containing the latest releases of the full WebX stack including:
 - [WebX Router](https://github.com/ILLGrenoble/webx-router)
 - [WebX Engine](https://github.com/ILLGrenoble/webx-engine)
 - [WebX Demo Server](https://github.com/ILLGrenoble/webx-demo-server)
 - [WebX Demo Client](https://github.com/ILLGrenoble/webx-demo-client)

The aim of the image is to demonstrate the full features of the WebX Router and WebX Engine:
 - The WebX Router provides multi-user remote desktop access including authentication, launching an X11 windows environment and spawning a WebX Engine
 - The WebX Engine provides a remote desktop protocol directly on top of the X11 environment (window-based as opposed to screen capturing)

The WebX Demo Server and Client are used to demonstrate the the [WebX Relay](https://github.com/ILLGrenoble/webx-relay) and [WebX Client](https://github.com/ILLGrenoble/webx-client) libraries used to embed the remote desktop capabilities of WebX into a web application.

In this image, `supervisor` is used to manage the WebX Router and the WebX Demo Server processes along with `Nginx` acting as a reverse proxy and serving the WebX Client web application.

Self-signed certificates are included in the container and the WebX Demo can be accessed at https://localhost

## Building from source

The WebX Demo image can be built using the following command:

```
docker build -t webx-demo .
```

## Running the WebX Demo

Run the container with the following command, exposing ports 80 and 443:

```
docker run --rm -p 80:80 -p 443:443 -h webx-demo webx-demo
```

Open a browser at https://localhost and you'll be able set the WebX Host to `localhost`.

The image is built with a number of preconfigured users: (mario, luigi, peach, toad, yoshi and bowser) - the password for these users is the same as the username.


