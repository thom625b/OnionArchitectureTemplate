# Simple template for setting up Onion architecture in C#

### If using ZSH follow this guide:

```zsh
# Create initial solution structure
mkdir OnionArchitecture
cd OnionArchitecture
dotnet new sln
mkdir client, server
cd server
mkdir Api.Rest, Api.Websocket, Application, Core.Domain, Infrastructure.Mqtt, Infrastructure.Postgres, Infrastructure.Postgres.Scaffolding, Infrastructure.Websocket, Startup, Startup.Tests
for dir in Api.Rest Api.Websocket Application Core.Domain Infrastructure.Mqtt Infrastructure.Postgres Infrastructure.Postgres.Scaffolding Infrastructure.Websocket; do dotnet new classlib -o $dir; done
dotnet new web -o Startup
dotnet new xunit -o Startup.Tests
cd ..
dotnet sln add server/Api.Rest/Api.Rest.csproj server/Api.Websocket/Api.Websocket.csproj server/Application/Application.csproj server/Core.Domain/Core.Domain.csproj server/Infrastructure.Mqtt/Infrastructure.Mqtt.csproj server/Infrastructure.Postgres/Infrastructure.Postgres.csproj server/Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj server/Infrastructure.Websocket/Infrastructure.Websocket.csproj server/Startup/Startup.csproj server/Startup.Tests/Startup.Tests.csproj

# Add project references
cd server
dotnet add Api.Rest/Api.Rest.csproj reference Application/Application.csproj
dotnet add Api.Websocket/Api.Websocket.csproj reference Application/Application.csproj
dotnet add Application/Application.csproj reference Core.Domain/Core.Domain.csproj
dotnet add Infrastructure.Mqtt/Infrastructure.Mqtt.csproj reference Application/Application.csproj
dotnet add Infrastructure.Postgres/Infrastructure.Postgres.csproj reference Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj
dotnet add Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj reference Application/Application.csproj
dotnet add Infrastructure.Websocket/Infrastructure.Websocket.csproj reference Application/Application.csproj
dotnet add Startup/Startup.csproj reference Api.Rest/Api.Rest.csproj Api.Websocket/Api.Websocket.csproj Infrastructure.Mqtt/Infrastructure.Mqtt.csproj Infrastructure.Postgres/Infrastructure.Postgres.csproj Infrastructure.Websocket/Infrastructure.Websocket.csproj Application/Application.csproj
dotnet add Startup.Tests/Startup.Tests.csproj reference Startup/Startup.csproj

# Add WebSocket packages
dotnet add Api.Websocket/Api.Websocket.csproj package uldahlalex.websocket.boilerplate --version 2.3.1
dotnet add Infrastructure.Websocket/Infrastructure.Websocket.csproj package uldahl.alex.websocket.boilerplate --version 2.3.1

# Add NuGet packages to all projects
dotnet add Api.Rest/Api.Rest.csproj package NSwag.AspNetCore --version 14.2.0 && dotnet add Api.Rest/Api.Rest.csproj package Scalar.AspNetCore --version 2.0.4
dotnet add Application/Application.csproj package JWT --version 11.0.0 && dotnet add Application/Application.csproj package Microsoft.Extensions.DependencyInjection.Abstractions --version 9.0.1 && dotnet add Application/Application.csproj package Microsoft.Extensions.Options --version 9.0.1 && dotnet add Application/Application.csproj package Microsoft.Extensions.Options.ConfigurationExtensions --version 9.0.1 && dotnet add Application/Application.csproj package Microsoft.Extensions.Configuration.Abstractions --version 9.0.1
dotnet add Infrastructure.Mqtt/Infrastructure.Mqtt.csproj package MQTTnet --version 5.0.1.1416 && dotnet add Infrastructure.Mqtt/Infrastructure.Mqtt.csproj package Scrutor --version 6.0.1
dotnet add Infrastructure.Postgres/Infrastructure.Postgres.csproj package Microsoft.EntityFrameworkCore -v 9.0.1 && dotnet add Infrastructure.Postgres/Infrastructure.Postgres.csproj package Microsoft.Extensions.DependencyInjection.Abstractions -v 9.0.1 && dotnet add Infrastructure.Postgres/Infrastructure.Postgres.csproj package PgCtxSetup -v 1.5.0
dotnet add Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj package Npgsql.EntityFrameworkCore.PostgreSQL -v 9 && dotnet add Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj package Microsoft.EntityFrameworkCore.Design -v 9 && dotnet add Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj package Microsoft.Extensions.DependencyInjection.Abstractions -v 9.0.1
dotnet add Startup/Startup.csproj package Microsoft.Extensions.Logging.Abstractions -v 9.0.2 && dotnet add Startup/Startup.csproj package Microsoft.Extensions.Logging.Console -v 9.0.2 && dotnet add Startup/Startup.csproj package Serilog -v 4.2.0 && dotnet add Startup/Startup.csproj package Serilog.AspNetCore -v 9.0.0 && dotnet add Startup/Startup.csproj package Serilog.Enrichers.Environment -v 3.0.1 && dotnet add Startup/Startup.csproj package Serilog.Enrichers.Thread -v 4.0.0 && dotnet add Startup/Startup.csproj package Serilog.Expressions -v 5.0.0 && dotnet add Startup/Startup.csproj package Serilog.Sinks.Console -v 6.0.0 && dotnet add Startup/Startup.csproj package NSwag.CodeGeneration.TypeScript -v 14.2.0 && dotnet add Startup/Startup.csproj package patrikvalentiny-WebSocketProxy -v 1.1.0 && dotnet add Startup/Startup.csproj package NSwag.AspNetCore -v 14.2.0 && dotnet add Startup/Startup.csproj package Scalar.AspNetCore -v 2.0.23
dotnet add Startup.Tests/Startup.Tests.csproj package Microsoft.AspNetCore.Mvc.Testing -v 8.0.6 && dotnet add Startup.Tests/Startup.Tests.csproj package PgCtxSetup -v 1.5.0 && dotnet add Startup.Tests/Startup.Tests.csproj package Moq -v 4.20.72 && dotnet add Startup.Tests/Startup.Tests.csproj package xunit -v 2.6.5 && dotnet add Startup.Tests/Startup.Tests.csproj package xunit.runner.visualstudio -v 2.5.7 && dotnet add Startup.Tests/Startup.Tests.csproj package Microsoft.NET.Test.Sdk -v 17.13.0 && dotnet add Startup.Tests/Startup.Tests.csproj package xunit.analyzers -v 1.10.0

# Create Docker configuration
cd ..
cat > Dockerfile << 'EOF'
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
EOF

# Create .dockerignore
cat > .dockerignore << 'EOF'
# .NET
*.swp
*.user
*.suo
*.vs
**/bin/
**/obj/
**/TestResults/
*.DotSettings

# React/Node
**/node_modules/
**/build/
**/dist/
**/coverage/
**/.env
**/.env.local
**/.env.development.local
**/.env.test.local
**/.env.production.local
**/npm-debug.log*
**/yarn-debug.log*
**/yarn-error.log*

# Development files
.git/
.github/
.gitignore
.vscode/
.idea/
*.md
LICENSE
*.log

# Docker
Dockerfile*
docker-compose*
.docker/
.dockerignore

# Misc
*.zip
*.tar.gz
*.rar
**/tmp/
**/temp/
**/.DS_Store
**/thumbs.db
EOF

# Create directory structure
cd server
mkdir -p Api.Rest/{Controllers,Extensions,Middleware} \
       Api.Websocket/{EventHandlers,Interfaces} \
       Application/{Interfaces,Models,Services} \
       Core.Domain/Entities \
       Infrastructure.Mqtt/{PublishingHandlers,SubscriptionHandlers} \
       Infrastructure.Postgres/Postgresql.Data \
       Infrastructure.Websocket/ConnectionManagerScopedModels \
       Startup/{Documentation,Properties,Proxy} \
       Startup.Tests/{Auth,EventTests,ObjectValidationTests,OpenApiTests,TestUtils}
touch Api.Rest/Controllers/.gitkeep \
      Api.Rest/Extensions/.gitkeep \
      Api.Rest/Middleware/.gitkeep \
      Api.Websocket/EventHandlers/.gitkeep \
      Api.Websocket/Interfaces/.gitkeep \
      Application/Interfaces/.gitkeep \
      Application/Models/.gitkeep \
      Application/Services/.gitkeep \
      Core.Domain/Entities/.gitkeep \
      Infrastructure.Mqtt/PublishingHandlers/.gitkeep \
      Infrastructure.Mqtt/SubscriptionHandlers/.gitkeep \
      Infrastructure.Postgres/Postgresql.Data/.gitkeep \
      Infrastructure.Websocket/ConnectionManagerScopedModels/.gitkeep \
      Startup/Documentation/.gitkeep \
      Startup/Properties/.gitkeep \
      Startup/Proxy/.gitkeep \
      Startup.Tests/Auth/.gitkeep \
      Startup.Tests/EventTests/.gitkeep \
      Startup.Tests/ObjectValidationTests/.gitkeep \
      Startup.Tests/OpenApiTests/.gitkeep \
      Startup.Tests/TestUtils/.gitkeep

# Initialize git
cd ..
git init
dotnet new gitignore
open .gitignore
# Edit .gitignore to add node_modules and dist
git add .
git commit -m "first commit"
```

### If using Powershell follow this guide:


```powershell
# Create initial solution structure
mkdir OnionArchitecture
cd OnionArchitecture
dotnet new sln
mkdir client, server
cd server
mkdir Api.Rest, Api.Websocket, Application, Core.Domain, Infrastructure.Mqtt, Infrastructure.Postgres, Infrastructure.Postgres.Scaffolding, Infrastructure.Websocket, Startup, Startup.Tests
"Api.Rest", "Api.Websocket", "Application", "Core.Domain", "Infrastructure.Mqtt", "Infrastructure.Postgres", "Infrastructure.Postgres.Scaffolding", "Infrastructure.Websocket" | ForEach-Object { dotnet new classlib -o $_ } 
dotnet new web -o Startup
dotnet new xunit -o Startup.Tests
cd ..
dotnet sln add server/Api.Rest/Api.Rest.csproj server/Api.Websocket/Api.Websocket.csproj server/Application/Application.csproj server/Core.Domain/Core.Domain.csproj server/Infrastructure.Mqtt/Infrastructure.Mqtt.csproj server/Infrastructure.Postgres/Infrastructure.Postgres.csproj server/Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj server/Infrastructure.Websocket/Infrastructure.Websocket.csproj server/Startup/Startup.csproj server/Startup.Tests/Startup.Tests.csproj

# Add project references
cd server
dotnet add Api.Rest/Api.Rest.csproj reference Application/Application.csproj
dotnet add Api.Websocket/Api.Websocket.csproj reference Application/Application.csproj
dotnet add Application/Application.csproj reference Core.Domain/Core.Domain.csproj
dotnet add Infrastructure.Mqtt/Infrastructure.Mqtt.csproj reference Application/Application.csproj
dotnet add Infrastructure.Postgres/Infrastructure.Postgres.csproj reference Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj
dotnet add Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj reference Application/Application.csproj
dotnet add Infrastructure.Websocket/Infrastructure.Websocket.csproj reference Application/Application.csproj
dotnet add Startup/Startup.csproj reference Api.Rest/Api.Rest.csproj Api.Websocket/Api.Websocket.csproj Infrastructure.Mqtt/Infrastructure.Mqtt.csproj Infrastructure.Postgres/Infrastructure.Postgres.csproj Infrastructure.Websocket/Infrastructure.Websocket.csproj Application/Application.csproj
dotnet add Startup.Tests/Startup.Tests.csproj reference Startup/Startup.csproj

# Add WebSocket packages
dotnet add Api.Websocket/Api.Websocket.csproj package uldahlalex.websocket.boilerplate --version 2.3.1
dotnet add Infrastructure.Websocket/Infrastructure.Websocket.csproj package uldahl.alex.websocket.boilerplate --version 2.3.1

# Add NuGet packages to all projects
dotnet add Api.Rest/Api.Rest.csproj package NSwag.AspNetCore --version 14.2.0; dotnet add Api.Rest/Api.Rest.csproj package Scalar.AspNetCore --version 2.0.4
dotnet add Application\Application.csproj package JWT --version 11.0.0; dotnet add Application\Application.csproj package Microsoft.Extensions.DependencyInjection.Abstractions --version 9.0.1; dotnet add Application\Application.csproj package Microsoft.Extensions.Options --version 9.0.1; dotnet add Application\Application.csproj package Microsoft.Extensions.Options.ConfigurationExtensions --version 9.0.1; dotnet add Application\Application.csproj package Microsoft.Extensions.Configuration.Abstractions --version 9.0.1
dotnet add Infrastructure.Mqtt/Infrastructure.Mqtt.csproj package MQTTnet --version 5.0.1.1416; dotnet add Infrastructure.Mqtt/Infrastructure.Mqtt.csproj package Scrutor --version 6.0.1
dotnet add Infrastructure.Postgres/Infrastructure.Postgres.csproj package Microsoft.EntityFrameworkCore -v 9.0.1; dotnet add Infrastructure.Postgres/Infrastructure.Postgres.csproj package Microsoft.Extensions.DependencyInjection.Abstractions -v 9.0.1; dotnet add Infrastructure.Postgres/Infrastructure.Postgres.csproj package PgCtxSetup -v 1.5.0
dotnet add Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj package Npgsql.EntityFrameworkCore.PostgreSQL -v 9; dotnet add Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj package Microsoft.EntityFrameworkCore.Design -v 9; dotnet add Infrastructure.Postgres.Scaffolding/Infrastructure.Postgres.Scaffolding.csproj package Microsoft.Extensions.DependencyInjection.Abstractions -v 9.0.1
dotnet add Startup/Startup.csproj package Microsoft.Extensions.Logging.Abstractions -v 9.0.2; dotnet add Startup/Startup.csproj package Microsoft.Extensions.Logging.Console -v 9.0.2; dotnet add Startup/Startup.csproj package Serilog -v 4.2.0; dotnet add Startup/Startup.csproj package Serilog.AspNetCore -v 9.0.0; dotnet add Startup/Startup.csproj package Serilog.Enrichers.Environment -v 3.0.1; dotnet add Startup/Startup.csproj package Serilog.Enrichers.Thread -v 4.0.0; dotnet add Startup/Startup.csproj package Serilog.Expressions -v 5.0.0; dotnet add Startup/Startup.csproj package Serilog.Sinks.Console -v 6.0.0; dotnet add Startup/Startup.csproj package NSwag.CodeGeneration.TypeScript -v 14.2.0; dotnet add Startup/Startup.csproj package patrikvalentiny-WebSocketProxy -v 1.1.0; dotnet add Startup/Startup.csproj package NSwag.AspNetCore -v 14.2.0; dotnet add Startup/Startup.csproj package Scalar.AspNetCore -v 2.0.23
dotnet add Startup.Tests/Startup.Tests.csproj package Microsoft.AspNetCore.Mvc.Testing -v 8.0.6; dotnet add Startup.Tests/Startup.Tests.csproj package PgCtxSetup -v 1.5.0; dotnet add Startup.Tests/Startup.Tests.csproj package Moq -v 4.20.72; dotnet add Startup.Tests/Startup.Tests.csproj package xunit -v 2.6.5; dotnet add Startup.Tests/Startup.Tests.csproj package xunit.runner.visualstudio -v 2.5.7; dotnet add Startup.Tests/Startup.Tests.csproj package Microsoft.NET.Test.Sdk -v 17.13.0; dotnet add Startup.Tests/Startup.Tests.csproj package xunit.analyzers -v 1.10.0

# Create Docker configuration
cd ..
New-Item -Path "Dockerfile" -ItemType "file" -Value @"
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
"@

# Create .dockerignore
New-Item -Path ".dockerignore" -ItemType "file" -Value @"
# .NET
*.swp
*.user
*.suo
*.vs
**/bin/
**/obj/
**/TestResults/
*.DotSettings

# React/Node
**/node_modules/
**/build/
**/dist/
**/coverage/
**/.env
**/.env.local
**/.env.development.local
**/.env.test.local
**/.env.production.local
**/npm-debug.log*
**/yarn-debug.log*
**/yarn-error.log*

# Development files
.git/
.github/
.gitignore
.vscode/
.idea/
*.md
LICENSE
*.log

# Docker
Dockerfile*
docker-compose*
.docker/
.dockerignore

# Misc
*.zip
*.tar.gz
*.rar
**/tmp/
**/temp/
**/.DS_Store
**/thumbs.db
"@

# Create directory structure
cd .\server\; 
# First create all directories
mkdir -Force Api.Rest\Controllers, Api.Rest\Extensions, Api.Rest\Middleware, Api.Websocket\EventHandlers, Api.Websocket\Interfaces, Application\Interfaces, Application\Models, Application\Services, Core.Domain\Entities, Infrastructure.Mqtt\PublishingHandlers, Infrastructure.Mqtt\SubscriptionHandlers, Infrastructure.Postgres\Postgresql.Data, Infrastructure.Websocket\ConnectionManagerScopedModels, Startup\Documentation, Startup\Properties, Startup\Proxy, Startup.Tests\Auth, Startup.Tests\EventTests, Startup.Tests\ObjectValidationTests, Startup.Tests\OpenApiTests, Startup.Tests\TestUtils

# Then create .gitkeep files in each directory
$dirs = @(
    "Api.Rest\Controllers", 
    "Api.Rest\Extensions", 
    "Api.Rest\Middleware", 
    "Api.Websocket\EventHandlers", 
    "Api.Websocket\Interfaces", 
    "Application\Interfaces", 
    "Application\Models", 
    "Application\Services", 
    "Core.Domain\Entities", 
    "Infrastructure.Mqtt\PublishingHandlers", 
    "Infrastructure.Mqtt\SubscriptionHandlers", 
    "Infrastructure.Postgres\Postgresql.Data", 
    "Infrastructure.Websocket\ConnectionManagerScopedModels", 
    "Startup\Documentation", 
    "Startup\Properties", 
    "Startup\Proxy", 
    "Startup.Tests\Auth", 
    "Startup.Tests\EventTests", 
    "Startup.Tests\ObjectValidationTests", 
    "Startup.Tests\OpenApiTests", 
    "Startup.Tests\TestUtils"
)

foreach ($dir in $dirs) {
    New-Item -Path "$dir\.gitkeep" -ItemType File -Force
}
# Initialize git
cd ..
git init
dotnet new gitignore
code .gitignore
# Add node_modules and dist to .gitignore
git add .
git commit -m "first commit"
```
