extends Node

const BASE_URL := "http://localhost:5140"

var device_id := ""
var coins := 0

@onready var http := HTTPRequest.new()

func _ready():
	add_child(http)
	device_id = _load_or_create_device_id()
	print("DeviceId:", device_id)
	_auth()

func _load_or_create_device_id() -> String:
	var path := "user://device_id.txt"

	if FileAccess.file_exists(path):
		var f = FileAccess.open(path, FileAccess.READ)
		var id = f.get_as_text().strip_edges()
		f.close()
		return id

	var id := str(Time.get_unix_time_from_system())
	var fw = FileAccess.open(path, FileAccess.WRITE)
	fw.store_string(id)
	fw.close()
	return id

func _auth():
	var url = BASE_URL + "/auth/anonymous?device_id=" + device_id
	http.request_completed.connect(_on_auth_done, CONNECT_ONE_SHOT)
	http.request(url, [], HTTPClient.METHOD_POST)

func _on_auth_done(result, response_code, headers, body):
	var bytes: PackedByteArray = body
	var text: String = bytes.get_string_from_utf8()

	print("Auth:", text)

	if response_code == 200:
		var data = JSON.parse_string(text)
		coins = int(data["coins"])
		print("Coins geladen:", coins)

func add_coins(amount: int):
	var url = BASE_URL + "/coins/add?device_id=" + device_id + "&amount=" + str(amount)
	http.request_completed.connect(_on_add_done, CONNECT_ONE_SHOT)
	http.request(url, [], HTTPClient.METHOD_POST)
	
func _on_add_done(result, response_code, headers, body):
	var bytes: PackedByteArray = body
	var text: String = bytes.get_string_from_utf8()

	print("Coins update:", text)

	if response_code == 200:
		var data = JSON.parse_string(text)
		coins = int(data["coins"])
		print("Neue Coins:", coins)
