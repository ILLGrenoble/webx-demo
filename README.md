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


## WebX Overview

WebX is a Remote Desktop technology allowing an X11 desktop to be rendered in a user's browser. It's aim is to allow a secure connection between a user's browser and a remote linux machine such that the user's desktop can be displayed and interacted with, ideally producing the effect that the remote machine is behaving as a local PC.

WebX's principal differentiation to other Remote Desktop technologies is that it manages individual windows within the display rather than treating the desktop as a single image. A couple of advantages with a window-based protocol is that window movement events are efficiently passed to clients (rather than graphically updating regions of the desktop) and similarly it avoids <em>tearing</em> render effects during the movement. WebX aims to optimise the flow of data from the window region capture, the transfer of data and client rendering.

The WebX remote desktop stack is composed of a number of different projects:
 - [WebX Engine](https://github.com/ILLGrenoble/webx-engine) The WebX Engine is the core of WebX providing a server that connects to an X11 display obtaining window parameters and images. It listens to X11 events and forwards event data to connected clients. Remote clients similarly interact with the desktop and the actions they send to the WebX Engine are forwarded to X11.
 - [WebX Router](https://github.com/ILLGrenoble/webx-router) The WebX Router manages multiple WebX sessions on single host, routing traffic between running WebX Engines and the WebX Relay. It authenticates session creation requests and spawns Xorg, window manager and WebX Engine processes.
 - [WebX Relay](https://github.com/ILLGrenoble/webx-relay) The WebX Relay provides a Java library that can be integrated into the backend of a web application, providing bridge functionality between WebX host machines and client browsers. TCP sockets (using the ZMQ protocol) connect the relay to host machines and websockets connect the client browsers to the relay. The relay transports data between a specific client and corresponding WebX Router/Engine.
 - [WebX Client](https://github.com/ILLGrenoble/webx-client) The WebX Client is a javascript package (available via NPM) that provides rendering capabilities for the remote desktop and transfers user input events to the WebX Engine via the relay.

## Running the WebX Demo

Run the image with the following command, exposing ports 80 and 443:

```
docker run --rm -p 80:80 -p 443:443 -h webx-demo ghcr.io/illgrenoble/webx-demo
```

Open a browser at https://localhost and you'll be able set the WebX Host to `localhost`.

The image is built with a number of preconfigured users: (mario, luigi, peach, toad, yoshi and bowser) - the password for these users is the same as the username.

## Building from source

The WebX Demo image can be built using the following command:

```
docker build -t webx-demo .
```

Run the local image using the command:

```
docker run --rm -p 80:80 -p 443:443 -h webx-demo webx-demo
```


