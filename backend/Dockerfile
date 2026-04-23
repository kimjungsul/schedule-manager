FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["ScheduleManager.Api/ScheduleManager.Api.csproj", "ScheduleManager.Api/"]
RUN dotnet restore "ScheduleManager.Api/ScheduleManager.Api.csproj"
COPY . .
WORKDIR "/src/ScheduleManager.Api"
RUN dotnet publish -c Release -o /app/publish
FROM mcr.microsoft.com/dotnet/aspnet:8.0
WORKDIR /app
COPY --from=build /app/publish .
ENTRYPOINT ["dotnet", "ScheduleManager.Api.dll"]
