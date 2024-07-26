# Use the official .NET SDK image to build the app
FROM mcr.microsoft.com/dotnet/sdk:6.0 AS build

WORKDIR /app

COPY *.csproj ./
RUN dotnet restore

COPY . ./
RUN dotnet publish -c Release -o out
RUN dotnet dev-certs https -ep /https/aspnetapp.pfx -p password

# Use the official ASP.NET Core runtime image to run the app
FROM mcr.microsoft.com/dotnet/aspnet:6.0

WORKDIR /app

# Copy the build output from the previous stage
COPY --from=build /app/out .
COPY --from=build /https/* /https/

# Copy the custom dictionary file
COPY App_Data/spellcheck.json /app/App_Data/spellcheck.json
COPY App_Data/customDict.dic /app/App_Data/customDict.dic

EXPOSE 80

ENTRYPOINT ["dotnet", "DocumentEditorCore.dll"]
