FROM node:24-alpine AS web-build
WORKDIR /src/web
COPY web/package*.json ./
RUN npm ci
COPY web/ ./
RUN npm run build

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS api-build
WORKDIR /src
COPY AsignacionAcademica.sln ./
COPY src/AsignacionAcademica.Api/AsignacionAcademica.Api.csproj src/AsignacionAcademica.Api/
COPY tests/AsignacionAcademica.Api.Tests/AsignacionAcademica.Api.Tests.csproj tests/AsignacionAcademica.Api.Tests/
RUN dotnet restore AsignacionAcademica.sln
COPY src/ src/
COPY tests/ tests/
RUN dotnet publish src/AsignacionAcademica.Api/AsignacionAcademica.Api.csproj -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS runtime
WORKDIR /app
EXPOSE 8080
ENV ASPNETCORE_URLS=http://+:8080
COPY --from=api-build /app/publish ./
COPY --from=web-build /src/web/dist ./wwwroot
ENTRYPOINT ["dotnet", "AsignacionAcademica.Api.dll"]
