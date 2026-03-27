---
title: Backend mit C#, ASP.NET Core und SQLite
---

# Goal

In diesem Tutorial lernst du, wie du ein einfaches Backend mit **C#**, **ASP.NET Core** und **SQLite** erstellst. Das Backend speichert Daten für ein kleines Spiel, zum Beispiel **Coins** und **Bestzeiten**.

Am Ende kannst du das Backend lokal starten, mit einer SQLite-Datenbank verbinden und Anfragen aus deinem Spiel an das Backend senden.

# Previous Knowledge

Für dieses Tutorial solltest du die Grundlagen von C# kennen. Es ist hilfreich, wenn du schon einmal mit Variablen, Funktionen und einfachen Klassen gearbeitet hast.

Grundkenntnisse in HTTP oder Datenbanken sind nützlich, aber nicht zwingend notwendig, weil alle Schritte erklärt werden.

# What you'll learn

In diesem Tutorial lernst du:

- wie du **.NET** und **SQLite** einrichtest  
- wie du ein **ASP.NET Core Backend** erstellst  
- wie du eine **SQLite-Datenbank** verwendest  
- wie du Daten wie Coins oder Zeiten speicherst  
- wie du ein einfaches **Leaderboard** aufbaust  
- wie du dein Spiel mit dem Backend verbindest  

# Tutorial

## 1. Was wir bauen

Wir bauen ein Backend für ein kleines 2D-Spiel. Das Backend kann:

- einen Spieler anhand einer `device_id` erkennen  
- Coins speichern  
- eine Zeit speichern  
- die besten Zeiten für ein Leaderboard zurückgeben  

Die Daten werden in einer SQLite-Datei gespeichert. Diese Datei heißt später `game.db`.

## 2. Benötigte Programme herunterladen

Für dieses Projekt brauchst du:

- **.NET SDK**
- **SQLite Tools**
- einen Code-Editor wie **Visual Studio Code**

### .NET prüfen

Öffne ein Terminal und gib ein:

```powershell
dotnet --version
```

Wenn eine Versionsnummer erscheint, ist .NET installiert.

### SQLite Tools

Lade die SQLite Tools herunter und entpacke sie in einen Ordner. Danach solltest du Dateien wie diese sehen:

```
sqlite3.exe
sqldiff.exe
sqlite3_analyzer.exe
sqlite3_rsync.exe
```

Für dieses Tutorial brauchst du vor allem:

```
sqlite3.exe
```

## 3. Backend-Projekt erstellen

Öffne ein Terminal in dem Ordner, in dem du dein Backend erstellen möchtest.

Erstelle ein neues Projekt:

```powershell
dotnet new web -n GameBackend
cd GameBackend
```

Dann installiere SQLite für C#:

```powershell
dotnet add package Microsoft.Data.Sqlite
```

Jetzt hast du ein leeres ASP.NET Core Projekt.

## 4. SQLite-Datenbank vorbereiten

In diesem Projekt wird die Datenbankdatei `game.db` verwendet. Sie liegt im gleichen Ordner wie das Backend.

Die Datenbank wird beim ersten Start automatisch erstellt. Dafür braucht das Backend eine Tabelle `players`.

## 5. Program.cs schreiben

Öffne die Datei `Program.cs` und ersetze den Inhalt mit diesem Code:

```csharp
using Microsoft.Data.Sqlite;

var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

string dbPath = "game.db";

void InitDb()
{
    using var connection = new SqliteConnection($"Data Source={dbPath}");
    connection.Open();

    var command = connection.CreateCommand();
    command.CommandText =
    @"
    CREATE TABLE IF NOT EXISTS players (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT UNIQUE NOT NULL,
        coins INTEGER NOT NULL DEFAULT 0,
        best_time REAL
    );

    CREATE TABLE IF NOT EXISTS runs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        device_id TEXT NOT NULL,
        time REAL NOT NULL,
        created_at TEXT DEFAULT CURRENT_TIMESTAMP
    );
    ";
    command.ExecuteNonQuery();
}

InitDb();

app.MapPost("/auth/anonymous", (string device_id) =>
{
    using var connection = new SqliteConnection($"Data Source={dbPath}");
    connection.Open();

    var select = connection.CreateCommand();
    select.CommandText = "SELECT coins FROM players WHERE device_id = $device_id";
    select.Parameters.AddWithValue("$device_id", device_id);

    var result = select.ExecuteScalar();

    if (result == null)
    {
        var insert = connection.CreateCommand();
        insert.CommandText = "INSERT INTO players (device_id, coins, best_time) VALUES ($device_id, 0, NULL)";
        insert.Parameters.AddWithValue("$device_id", device_id);
        insert.ExecuteNonQuery();

        return Results.Ok(new { coins = 0 });
    }

    return Results.Ok(new { coins = Convert.ToInt32(result) });
});

app.MapGet("/coins", (string device_id) =>
{
    using var connection = new SqliteConnection($"Data Source={dbPath}");
    connection.Open();

    var cmd = connection.CreateCommand();
    cmd.CommandText = "SELECT coins FROM players WHERE device_id = $device_id";
    cmd.Parameters.AddWithValue("$device_id", device_id);

    var result = cmd.ExecuteScalar();
    if (result == null) return Results.NotFound(new { error = "Player not found" });

    return Results.Ok(new { coins = Convert.ToInt32(result) });
});

app.MapPost("/coins/add", (string device_id, int amount) =>
{
    if (amount <= 0 || amount > 50)
        return Results.BadRequest(new { error = "amount must be between 1 and 50" });

    using var connection = new SqliteConnection($"Data Source={dbPath}");
    connection.Open();

    var ensure = connection.CreateCommand();
    ensure.CommandText = "INSERT OR IGNORE INTO players (device_id, coins, best_time) VALUES ($device_id, 0, NULL)";
    ensure.Parameters.AddWithValue("$device_id", device_id);
    ensure.ExecuteNonQuery();

    var update = connection.CreateCommand();
    update.CommandText = "UPDATE players SET coins = coins + $amount WHERE device_id = $device_id";
    update.Parameters.AddWithValue("$amount", amount);
    update.Parameters.AddWithValue("$device_id", device_id);
    update.ExecuteNonQuery();

    var select = connection.CreateCommand();
    select.CommandText = "SELECT coins FROM players WHERE device_id = $device_id";
    select.Parameters.AddWithValue("$device_id", device_id);

    var coins = Convert.ToInt32(select.ExecuteScalar());
    return Results.Ok(new { coins });
});

app.MapPost("/time/submit", (string device_id, double time) =>
{
    using var connection = new SqliteConnection($"Data Source={dbPath}");
    connection.Open();

    var ensure = connection.CreateCommand();
    ensure.CommandText = "INSERT OR IGNORE INTO players (device_id, coins, best_time) VALUES ($device_id, 0, NULL)";
    ensure.Parameters.AddWithValue("$device_id", device_id);
    ensure.ExecuteNonQuery();

    var insertRun = connection.CreateCommand();
    insertRun.CommandText = "INSERT INTO runs (device_id, time) VALUES ($device_id, $time)";
    insertRun.Parameters.AddWithValue("$device_id", device_id);
    insertRun.Parameters.AddWithValue("$time", time);
    insertRun.ExecuteNonQuery();

    var getCmd = connection.CreateCommand();
    getCmd.CommandText = "SELECT best_time FROM players WHERE device_id = $device_id";
    getCmd.Parameters.AddWithValue("$device_id", device_id);

    var current = getCmd.ExecuteScalar();

    if (current == null || current == DBNull.Value || time < Convert.ToDouble(current))
    {
        var update = connection.CreateCommand();
        update.CommandText = "UPDATE players SET best_time = $time WHERE device_id = $device_id";
        update.Parameters.AddWithValue("$time", time);
        update.Parameters.AddWithValue("$device_id", device_id);
        update.ExecuteNonQuery();
    }

    return Results.Ok(new { submitted_time = time });
});

app.MapGet("/leaderboard", () =>
{
    using var connection = new SqliteConnection($"Data Source={dbPath}");
    connection.Open();

    var cmd = connection.CreateCommand();
    cmd.CommandText = @"
        SELECT device_id, time
        FROM runs
        ORDER BY time ASC
        LIMIT 3
    ";

    using var reader = cmd.ExecuteReader();

    var leaderboard = new List<object>();

    while (reader.Read())
    {
        leaderboard.Add(new
        {
            device_id = reader.GetString(0),
            best_time = reader.GetDouble(1)
        });
    }

    return Results.Ok(leaderboard);
});

app.Run();
```

## 6. Backend starten

Speichere die Datei und starte den Server mit:

```powershell
dotnet run
```

Wenn alles funktioniert, solltest du etwas sehen wie:

``` id="backend_output_example"
Now listening on: http://localhost:5140
```

Dann läuft dein Backend lokal.

## 7. Datenbank mit sqlite3 prüfen

Wenn du prüfen möchtest, ob Daten wirklich gespeichert werden, öffnest du ein zweites Terminal.

Gehe in den Ordner, in dem `sqlite3.exe` und `game.db` liegen, und gib ein:

```powershell
.\sqlite3.exe game.db
```

Dann kannst du SQL-Befehle benutzen.

### Tabelle anzeigen

```sql
.schema players
.schema runs
```

### Gespeicherte Spieler anzeigen

```sql
SELECT * FROM players;
```

### Gespeicherte Zeiten anzeigen

```sql
SELECT * FROM runs ORDER BY time ASC;
```

SQLite wieder schließen:

```sql
.exit
```
## 8. Verbindung mit dem Spiel

Das Spiel schickt HTTP-Anfragen an das Backend. Dafür habe ich in Godot einen `BackendClient` verwendet, der Requests an `http://localhost:5140` sendet.

### Beispiel für Zeit speichern

```gdscript
func submit_time(time_value: float):
    var url = BASE_URL + "/time/submit?device_id=" + device_id + "&time=" + str(time_value)
    http.request_completed.connect(_on_time_submitted, CONNECT_ONE_SHOT)
    http.request(url, [], HTTPClient.METHOD_POST)
```

### Beispiel für Leaderboard laden

```gdscript
func get_leaderboard():
    var url = BASE_URL + "/leaderboard"
    leaderboard_http.request_completed.connect(_on_leaderboard_received, CONNECT_ONE_SHOT)
    leaderboard_http.request(url, [], HTTPClient.METHOD_GET)
```

Dadurch kann das Spiel die Daten an das Backend senden und auch wieder abrufen.

## 9. Wie das System funktioniert

Das Backend speichert zwei Arten von Daten:

### Players

In `players` wird pro Spieler gespeichert:

- `device_id`  
- `coins`  
- `best_time`  

### Runs

In `runs` wird jeder abgeschlossene Lauf gespeichert:

- `device_id`  
- `time`  
- `created_at`  

Das ist wichtig, weil man so:

- die persönliche Bestzeit speichern kann  
- und gleichzeitig ein echtes Top-3-Leaderboard bauen kann  

## 10. Wichtige Terminal-Befehle

### Projekt erstellen

```powershell
dotnet new web -n GameBackend
cd GameBackend
```

### SQLite-Paket installieren

```powershell
dotnet add package Microsoft.Data.Sqlite
```

### Backend starten

```powershell
dotnet run
```

### SQLite öffnen

```powershell
.\sqlite3.exe game.db
```

### Tabellen prüfen

```sql
.schema players
.schema runs
SELECT * FROM players;
SELECT * FROM runs;
```

# Result

Nach diesem Tutorial hast du ein funktionierendes Backend mit C#, ASP.NET Core und SQLite erstellt.

Das Backend kann:

- Coins speichern  
- Zeiten speichern  
- die drei besten Zeiten als Leaderboard zurückgeben  

Außerdem weißt du jetzt:

- wie man eine SQLite-Datenbank überprüft  
- wie man Endpoints erstellt  
- wie ein Spiel mit dem Backend kommuniziert  

# What could go wrong?

Ein häufiges Problem ist, dass man die falsche `game.db` bearbeitet. Wenn das Backend mit `dbPath = "game.db"` arbeitet, wird die Datenbank im aktuellen Backend-Ordner verwendet.

Ein weiteres Problem ist, dass SQLite-Befehle nur innerhalb von `sqlite3.exe` funktionieren. Befehle wie `.schema` oder `ALTER TABLE` darf man also nicht direkt in PowerShell eingeben.

Außerdem muss man bei JSON-Antworten darauf achten, dass die Namen der Felder im Backend und im Spiel genau übereinstimmen. Wenn zum Beispiel das Backend `submitted_time` zurückgibt, das Spiel aber `best_time` erwartet, entsteht ein Fehler.
