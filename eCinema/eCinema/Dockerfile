FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["eCinema.sln", "."]
COPY ["eCinema/eCinema.csproj", "eCinema/"]
COPY ["eCinema.Subscriber/eCinema.Subscriber.csproj", "eCinema.Subscriber/"]
COPY ["eCinema.Services/eCinema.Services.csproj", "eCinema.Services/"]
COPY ["eCinema.Models/eCinema.Models.csproj", "eCinema.Models/"]

RUN dotnet restore "eCinema.sln"


COPY . .
WORKDIR "/src/eCinema"
RUN dotnet publish "eCinema.csproj" -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .

EXPOSE 80

ENTRYPOINT ["dotnet", "eCinema.dll"]