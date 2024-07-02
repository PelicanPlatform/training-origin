# HTC24 Pelican Tutorial

This repository contains the materials that will be used during the [HTC24 Pelican Tutorial](https://agenda.hep.wisc.edu/event/2175/sessions/3189/#20240710).

The following instructions assume the computer you are using has Docker and the web host certificates for using https, and that you have permission to use the OSDF ITB data federation (`osdf-itb.osg-htc.org`).
HTC24 tutorial participants will be given access to a virtual machine that satisfies these requirements.

This tutorial uses Pelican v7.9.2.

**Jump to:**

* [Setup](#setup)
* [Using the Pelican Client to Transfer Data](#using-the-pelican-client-to-transfer-data)
* [Configuring Your Pelican Origin](#configuring-your-pelican-origin)
* [Initialize and Serve Your Pelican Origin](#initialize-and-serve-your-pelican-origin)
* [Transferring Data with Your Pelican Origin](#transferring-data-with-your-pelican-origin)

## Setup

> These instructions are for HTC24 participants only and will not work for other users.

You must have registered prior to the tutorial to be given access to a virtual machine for use during the tutorial.
Separate instructions were emailed to participants who signed up in advance. 

If you registered in advance, you can log in to your virtual machine with

```
ssh <comanage-username>@pelicanbastion.chtc.wisc.edu
```

where the `<comanage-username>` can be found in your registration information.
You will be signed into a dedicated virtual machine for your use only.
You should see something like

```
[pelicanuser@pelicantrain20## ~]$
```

for your command prompt.

The rest of this document contains the commands that will be executed during the course of the tutorial.
Explanations of what is being done and why are provided in the accompanying presentation.

## Using the Pelican Client to Transfer Data

More information on the Pelican CLient can be found here: []().

### Download and Extract the Pelican Client

1. Create a directory for the client

   ```
   mkdir $HOME/pelican-client
   cd $HOME/pelican-client
   ```

2. Download the client tarball from the Pelican Platform 

   ```
   wget https://github.com/PelicanPlatform/pelican/releases/download/v7.9.2/pelican_Linux_x86_64.tar.gz
   ```

   This link comes from the "Install" page of the documentation for Pelican ([https://docs.pelicanplatform.org/install](https://docs.pelicanplatform.org/install))
   for the file `pelican_Linux_x86_64.tar.gz`.

3. Decompress the client

   ```
   tar -xzf pelican_Linux_x86_64.tar.gz
   ```

   This will create a directory `pelican-7.9.2`, which in turn contains the client binary.

   ```
   [pelicanuser@pelicantrain20## pelican-client]$ ls
   pelican-7.9.2 pelican_Linux_x86_64.tar.gz
   [pelicanuser@pelicantrain20## pelican-client]$ cd pelican-7.9.2
   [pelicanuser@pelicantrain20## pelican-7.9.2]$ ls
   LICENSE pelican README.md
   ```

### Use the Pelican Client

1. "Get" the test object from the OSDF

   ```
   ./pelican object get pelican://osg-htc.org/ospool/uc-shared/public/OSG-Staff/validation/test.txt downloaded-test.txt
   ```

2. Check the file contents

   ```
   [pelicanuser@pelicantrain20## pelican-7.9.2]$ ls
   downloaded-test.txt LICENSE pelican README.md
   [pelicanuser@pelicantrain20## pelican-7.9.2]$ cat downloaded-test.txt
   Hello, World!
   ```

## Configuring Your Pelican Origin

We have pre-generated some of the files and directories for organizing and configuring the Pelican Origin for this tutorial.
This structure is not required in order to run your own Pelican Origin.

### Prepare the Origin Directories

1. Copy the pre-generated files

   ```
   cp -R /etc/pelican-origin $HOME/pelican-origin
   cd $HOME/pelican-origin
   ```

2. Explore the pre-generated files

   ```
   [pelicanuser@pelicantrain20## pelican-origin]$ ls
   config origin-data
   [pelicanuser@pelicantrain20## pelican-origin]$ ls config/
   pelican.yaml
   [pelicanuser@pelicantrain20## pelican-origin]$ ls origin-data/
   test.txt
   [pelicanuser@pelicantrain20## pelican-origin]$ cat origin-data/test.txt
   Hello World, from HTC24!
   ```

The files are organized as such:

```
$HOME/pelican-origin
├── config
│   ├── pelican.yaml
└── origin-data
    └── test.txt
```

### Generate the Issuer JWK

To make it easier to restart the Origin and serve a specific namespace, we are going to pre-generate the Issuer keys in the `pelican-origin/config` directory. 

1. Move to the origin config directory

   ```
   cd $HOME/pelican-origin/config
   ```

2. Generate the Issuer JWK files using a Pelican container

   ```
   docker run --rm --entrypoint '' \
       -v $(pwd):$(pwd) -w $(pwd) \
       hub.opensciencegrid.org/pelican_platform/origin:v7.9.2 \
       /pelican/pelican generate keygen
   ```

   This command will pull a Pelican docker container (in this case, the `origin` one, but any should work), override the default entrypoint, and then generate the Issuer JWK files in the current directory.

3. Confirm the Issuer JWK files were created

   ```
   [pelicanuser@pelicantrain20## config]$ ls
   issuer.jwk issuer-pub.jwks pelican.yaml
   ```

### Edit/Explore the Pelican Configuration File (pelican.yaml)

Pelican uses a YAML file to provide the configuration for its services, typically located at `/etc/pelican/pelican.yaml`.

Each Origin has at least three unique entries in the configuration file: (i) the data federation URL it is joining, (ii) the "federation prefix" or "namespace" that it will serve in that data federation, and (iii) the hostname of the web host that is running the Origin.

For this tutorial, your Origin will be joining the test instance of the OSDF and serving the namespace `/HTC24-<vm-name>` from the web host `<vm-name>.chtc.wisc.edu`.
We've provided most of the necessary configuration in the `pelican.yaml` file you copied above, including the federation URL for the OSDF test instance, but you will need to update the config with the name of your specific virtual machine.

1. Update the config with the name of your virtual machine

   For example, if you are logged into `pelicantrain2001`, you would run the following command:

   ```
   sed -i 's/<vm-name>/pelicantrain2001/g' pelican.yaml
   ```

   or else use a command-line text editor to make the changes manually in the configuration file.

   a. **Namespace**

      *Before:* `    - FederationPrefix: "/HTC24-<vm-name>"`
   
      *After:* `    - FederationPrefix: "/HTC24-pelicantrain2001"`
    
   b. **Hostname**

      *Before:* `  Hostname: "<vm-name>.chtc.wisc.edu"`
   
      *After:* `  Hostname: "pelicantrain2001.chtc.wisc.edu"`

3. Explore the contents of the `pelican.yaml` file

   Use `cat` or your favorite CLI tool to explore the contents of the `pelican.yaml` file.
   Comments about the various sections are included.

## Initialize and Serve Your Pelican Origin

Pelican Platform recommends using their provided Docker containers to run any Pelican Services, such as an Origin.

### Start the Origin service

1. Move to the `pelican-origin` directory

   ```
   cd $HOME/pelican-origin
   ```

   You should see the following contents:

   ```
   [pelicanuser@pelicantrain20## pelican-origin]$ ls -R
   .:
   config  origin-data

   ./config:
   issuer.jwk  issuer-pub.jwks  pelican.yaml

   ./origin-data:
   test.txt
   ```

2. Start the Docker container, and ***leave it running***

   ```
   docker run --rm -it \
       -p 8444:8444 -p 8443:8443 \
       -v $(pwd)/config/issuer.jwk:/etc/pelican/issuer.jwk \
       -v $(pwd)/config/issuer-pub.jwks:/etc/pelican/issuer-pub.jwks \
       -v /etc/hostcert.pem:/etc/hostcert.pem \
       -v /etc/hostkey.pem:/etc/hostkey.pem \
       -v $(pwd)/config/pelican.yaml:/etc/pelican/pelican.yaml \
       -v $(pwd)/origin-data:/data \
       hub.opensciencegrid.org/pelican_platform/origin:v7.9.2 \
       serve -p 8444
   ```

### Initialize the Web Interface

When you run the above docker command, there will be a bunch of start-up information printed out (including the Pelican version information).
Then, there will be message saying "Pelican admin interface is not initialized" and provide a URL and a one-time code.
The URL will use the web host described in the config, i.e., the `pelicantrain20##.chtc.wisc.edu` address you provided as the `Hostname` in the `pelican.yaml` file.

For example, 

```
Pelican admin interface is not initialized
To initialize, login at https://pelicantrain2001.chtc.wisc.edu:8444/view/initialization/code/ with the following code:
185819
```

1. In your browser, go to the URL that *your* command printed out

2. Enter the one-time code to activate the interface

3. [Optional] Provide an admin password. (If you do, and you close your browser, you will need to enter this password to login to the interface again.)

Some notes: 

* If you take too long to activate the interface, a new one-time code may be printed out in the terminal running your Docker container.

* The password you provide will be saved in the `/etc/pelican` directory, but since that is located in a non-bound directory in the Docker container, it will not exist once the container exits. 

* Unless you've mounted the `/etc/pelican` directory into the container, you will have to repeat the admin initialization step if you restart the Origin container.

### Explore the Web Interface

Pelican Platform has web interfaces for all of the services that it can run, providing a more convenient way of interacting with and managing Pelican services.

For the Origin interface, there are status boxes for each component/connection that the Origin has (Directory, Federation, Registry, Web UI, XRootD).
You can also see information about the data source and the corresponding namespace, and the permissions associated with the data.
There is even a graph for monitoring the data transfer rates.

Furthermore, the web interfaces allow you to see and change the configuration for the service.
The configuration can be accessed by clicking the gray wrench in the top left corner.

## Transferring Data with Your Pelican Origin

If there aren't any red boxes web interface for your Origin, then you are ready to transfer data from your Origin!

**For the following commands, log in to your virtual machine from a new terminal window.**
***Do not stop or close out of the terminal where you ran the Docker command to launch your Origin!!***

> If you accidentally stop the Origin service for some reason, return to the previous section ([Initialize and Serve Your Pelican Origin](#initialize-and-serve-your-pelican-origin)) and repeat the steps.

### Download Directly From Your Origin

To start, you will download your data directly from the Origin, bypassing the cache system that is used by default.

1. Move to the Client directory

   ```
   cd $HOME/pelican-client/pelican-7.9.2
   ```

2. Get your object directly using the `?directread` option.

   ```
   ./pelican object get pelican://osdf-itb.osg-htc.org/HTC24-pelicantrain20##/test.txt?directread ./directread-test.txt
   ```

   You will need to change `pelicantrain20##` to the number used by your specific virtual machine, e.g., `pelicantrain2001`.

3. Check the contents of the downloaded object

   ```
   cat directread-test.txt
   ```

   The contents should match those of the file `$HOME/pelican-origin/origin-data/test.txt`.

### Download Using the Caching System

After your Origin has been online for a few minutes, you can use the caching system to transfer the file, which is default mechanism of transfer.

1. Get your object 

   ```
   ./pelican object get pelican://osdf-itb.osg-htc.org/HTC24-pelicantrain20##/test.txt ./cacheread-test.txt
   ```

2. Check the contents of the downloaded object

   ```
   cat cacheread-test.txt
   ```

### Rename the Object in the Origin and Download Again

Now you will explore how the caching system works.

1. Remove the previously downloaded objects

   ```
   rm directread-test.txt cacheread-test.txt
   ```

2. Move to the `origin-data` folder and rename the `test.txt` file

   ```
   cd $HOME/pelican-origin/origin-data
   mv test.txt renamed-test.txt
   ```

3. Move back to the Client folder

   ```
   cd $HOME/pelican-client/pelican-7.9.2
   ```

4. Try to download the object directly

   ```
   ./pelican object get pelican://osdf-itb.osg-htc.org/HTC24-pelicantrain20##/test.txt?directread ./directread-test.txt
   ```

   This will FAIL! 

5. Try to download the object using caching system (default)

   ```
   ./pelican object get pelican://osdf-itb.osg-htc.org/HTC24-pelicantrain20##/test.txt ./cacheread-test.txt
   ```

   This will SUCCEED!

Because the object `/HTC24-pelicantrain20##/test.txt` had been previously transferred using the caching system, a copy of that object *was kept in a cache*.
By default, Pelican attempts to transfer objects from the nearest cache.
So the default transfer attempt succeeded for `/HTC24-pelicantrain20##/test.txt` because the Client downloaded the object from a cache.
The attempt at downloading the object directly from the Origin failed, because that object no longer existed at the Origin.

This behavior applies generally to any change to objects stored in the Origin.
If you change the name or contents of an object in the Origin, that change is **not** propagated to the caches where a copy of that object may be stored.
And since by default the Client will download objects from a cache (if a copy of that object exists in a cache), that means the Client will download an older version of the object.