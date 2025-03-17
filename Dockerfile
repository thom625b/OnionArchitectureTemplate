FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
WORKDIR /src
COPY . .
RUN dotnet restore "server/Startup/Startup.csproj"
RUN dotnet publish "server/Startup/Startup.csproj" -c Release -o /app/publish

FROM mcr.microsoft.com/dotnet/aspnet:9.0
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://0.0.0.0:8080
EXPOSE 8080
EXPOSE 5000
EXPOSE 8181
EXPOSE 8883
ENTRYPOINT ["dotnet", "Startup.dll"]