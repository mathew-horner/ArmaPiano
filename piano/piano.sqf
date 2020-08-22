#define KEYCODE_ESCAPE 1
#define KEYCODE_SPACE 57
#define PIANO_IDD 999
#define BASE_IDC 1000
#define SUSTAIN_BACKGROUND_IDC 1036
#define RECORD_BUTTON_IDC 1037
#define PLAY_BUTTON_IDC 1038

PIANO_keyControlMap = [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 1000, 1001, 1002, 1003, 1004, 1005, 1006, 1007, 1008, 1009, 1010, 1011, 1023, 1035, 1012, 1013, 1014, 1015, 1016, 1017, 1018, 1019, 1020, 1021, 1022, -1, -1, -1, 1024, 1025, 1026, 1027, 1028, 1029, 1030, 1031, 1032, 1033, 1034];
PIANO_keySoundMap = ["C3", "Csh3", "D3", "Dsh3", "E3", "F3", "Fsh3", "G3", "Gsh3", "A3", "Ash3", "B3", "C4", "Csh4", "D4", "Dsh4", "E4", "F4", "Fsh4", "G4", "Gsh4", "A4", "Ash4", "B4", "C5", "Csh5", "D5", "Dsh5", "E5", "F5", "Fsh5", "G5", "Gsh5", "A5", "Ash5", "B5"];

PIANO_soundObjects = [];
PIANO_keyOriginalColorMap = [];
PIANO_keyHeld = [];

PIANO_keyDownHandlerId = -1;
PIANO_keyUpHandlerId = -1;

PIANO_sustain = false;

PIANO_playingBack = false;
PIANO_recording = false;
PIANO_recordingData = [];
PIANO_recordingStart = -1;

PIANO_fnc_keyDownHandler = {
	_keyCode = _this select 1;

	if (_keyCode == KEYCODE_ESCAPE) exitWith {
		(findDisplay 46) displayRemoveEventHandler ["KeyDown", PIANO_keyDownHandlerId];
		(findDisplay 46) displayRemoveEventHandler ["KeyUp", PIANO_keyUpHandlerId];
		closeDialog 0;
		true
	};

	if (PIANO_playingBack) exitWith { false };

	if (_keyCode == KEYCODE_SPACE) exitWith {
		PIANO_sustain = true;
		ctrlSetText [SUSTAIN_BACKGROUND_IDC, "#(argb,8,8,3)color(1,0,0,0.8)"];
		true
	};

	if (_keyCode < count PIANO_keyControlMap) then {
		_idc = PIANO_keyControlMap select _keyCode;

		if (_idc != -1) exitWith {
			_keyIndex = _idc - BASE_IDC;
			if (!(PIANO_keyHeld select _keyIndex)) then {
				_existing = PIANO_soundObjects select _keyIndex;
				
				if (!isNull _existing) then {
					[_keyIndex, "UP"] call PIANO_fnc_recordNote;
					_existing spawn PIANO_fnc_silenceObject;
				};

				[_keyIndex, "DOWN"] call PIANO_fnc_recordNote;
				[_keyIndex] call PIANO_fnc_playNote;
				PIANO_keyHeld set [_keyIndex, true];

				ctrlSetText [_idc, "#(argb,8,8,3)color(1,0,0,1)"];
			};

			true
		};
	};

	false
};

PIANO_fnc_keyUpHandler = {
	_keyCode = _this select 1;

	if (_keyCode == KEYCODE_SPACE) exitWith {
		PIANO_sustain = false;
		ctrlSetText [SUSTAIN_BACKGROUND_IDC, "#(argb,8,8,3)color(0,0,0,0.8)"];
		{
			if (!isNull _x && !(PIANO_keyHeld select _forEachIndex)) then {
				[_forEachIndex, "UP"] call PIANO_fnc_recordNote;
				[_forEachIndex] call PIANO_fnc_silenceNote;
			};

		} forEach PIANO_soundObjects;

		true
	};

	if (_keyCode < count PIANO_keyControlMap) then {
		_idc = PIANO_keyControlMap select _keyCode;
		if (_idc != -1) exitWith {
			_keyIndex = _idc - BASE_IDC;
			ctrlSetText [_idc, PIANO_keyOriginalColorMap select _keyIndex];

			if (!PIANO_sustain) then {
				[_keyIndex, "UP"] call PIANO_fnc_recordNote;
				[_keyIndex] call PIANO_fnc_silenceNote;
			};

			PIANO_keyHeld set [_keyIndex, false];
			true
		};
	};

	false
};

PIANO_fnc_open = {
	createDialog "piano";

	for "_i" from 0 to 35 do {
		PIANO_keyOriginalColorMap pushBack (ctrlText (BASE_IDC + _i));
		PIANO_soundObjects pushBack objNull;
		PIANO_keyHeld pushBack false;
	};

	waitUntil {!isNull (findDisplay 46)};
	PIANO_keyDownHandlerId = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call PIANO_fnc_keyDownHandler"];
	PIANO_keyUpHandlerId = (findDisplay 46) displayAddEventHandler ["KeyUp", "_this call PIANO_fnc_keyUpHandler"];
};

PIANO_fnc_silenceObject = {
	sleep 0.1;
	deleteVehicle _this;
};

PIANO_fnc_playNote = {
	params ["_keyIndex"];
	_obj = "Land_HelipadEmpty_F" createVehicle (getPos player);
	_obj say [PIANO_keySoundMap select _keyIndex, 100];
	PIANO_soundObjects set [_keyIndex, _obj];
};

PIANO_fnc_silenceNote = {
	params ["_keyIndex"];
	(PIANO_soundObjects select _keyIndex) spawn PIANO_fnc_silenceObject;
	PIANO_soundObjects set [_keyIndex, objNull];
};

PIANO_fnc_recordNote = {
	params ["_keyIndex", "_direction"];
	if (!PIANO_recording) exitWith {};
	_data = [_keyIndex, _direction, time - PIANO_recordingStart];
	PIANO_recordingData pushBack _data;
};

PIANO_fnc_playback = {
	if (PIANO_playingBack) exitWith {};

	PIANO_playingBack = true;
	_start = time;

	{
		_keyIndex = _x select 0;
		_direction = _x select 1;
		_eventTime = _x select 2;

		waitUntil {time - _start >= _eventTime};

		// @TODO: Probably need to refactor this code because sustained notes show as being held which makes the playback look a bit wonky.
		// We should account for sustain pedal activity as well and display that appropriately.
		switch (_direction) do {
			case "DOWN": {
				[_keyIndex] call PIANO_fnc_playNote;
				ctrlSetText [BASE_IDC + _keyIndex, "#(argb,8,8,3)color(1,0,0,1)"];
			};
			case "UP": {
				[_keyIndex] call PIANO_fnc_silenceNote;
				ctrlSetText [BASE_IDC + _keyIndex, PIANO_keyOriginalColorMap select _keyIndex];
			};
		};
		
	} forEach PIANO_recordingData;

	PIANO_playingBack = false;
};

PIANO_fnc_startRecording = {
	PIANO_recording = true;
	PIANO_recordingData = [];
	PIANO_recordingStart = time;
};
