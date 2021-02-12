FROM mcr.microsoft.com/windows/servercore:1803 as installer

SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop';$ProgressPreference='silentlyContinue';"]

RUN Invoke-WebRequest -OutFile nodejs.zip -UseBasicParsing "https://nodejs.org/dist/v12.4.0/node-v12.4.0-win-x64.zip"; Expand-Archive nodejs.zip -DestinationPath C:\; Rename-Item "C:\node-v12.4.0-win-x64" -NewName "nodejs"

FROM mcr.microsoft.com/windows/nanoserver:1803 AS host

WORKDIR C:/nodejs
COPY --from=installer C:/nodejs/ .
RUN SETX PATH C:/nodejs
RUN npm config set registry https://registry.npmjs.org/


# adjust origin to Windows specific path
WORKDIR C:/azurite
COPY package.json c:/azurite/
COPY package-lock.json c:/azurite/

RUN npm install

COPY bin c:/azurite/bin
COPY lib c:/azurite/lib
COPY test c:/azurite/test

# From origin Dockerfile
# WORKDIR /opt/azurite
# 
# COPY package.json package-lock.json /opt/azurite/
# RUN npm install
# 
# COPY bin /opt/azurite/bin
# COPY lib /opt/azurite/lib
# COPY test /opt/azurite/test

# VOLUME c:/azurite/folder
# 
# Blob Storage Emulator
EXPOSE 10000
# Azure Queue Storage Emulator
EXPOSE 10001
# Azure Table Storage Emulator
EXPOSE 10002
# 
ENV executable azurite
#ENV PATH "c:\nodejs\;%PATH%"
# 
# CMD ["sh", "-c", "node bin/${executable} -l /opt/azurite/folder"]
# 
RUN c:\nodejs\node.exe --version
RUN npm --version

# CMD ["c:\\nodejs\\node.exe", "c:\\azurite\\bin\\azurite -l c:\\azurite\\folder\\store'"]
CMD ["c:\\nodejs\\node.exe", "c:\\azurite\\bin\\azurite"]
