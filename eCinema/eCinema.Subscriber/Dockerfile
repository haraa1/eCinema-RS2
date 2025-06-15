FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src

COPY ["eCinema.sln", "."]
COPY ["eCinema/eCinema.csproj", "eCinema/"]
COPY ["eCinema.Subscriber/eCinema.Subscriber.csproj", "eCinema.Subscriber/"]
COPY ["eCinema.Services/eCinema.Services.csproj", "eCinema.Services/"]
COPY ["eCinema.Models/eCinema.Models.csproj", "eCinema.Models/"]

RUN dotnet restore "eCinema.sln"

COPY . .
WORKDIR "/src/eCinema.Subscriber"
RUN dotnet publish "eCinema.Subscriber.csproj" -c Release -o /app/publish --no-restore

FROM mcr.microsoft.com/dotnet/runtime:8.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "eCinema.Subscriber.dll"]