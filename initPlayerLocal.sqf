PIANO_keyControlMap = [
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	-1,
	1000,
	1001,
	1002,
	1003,
	1004,
	1005,
	1006,
	1007,
	1008,
	1009,
	1010,
	1011,
	1023,
	1035,
	1012,
	1013,
	1014,
	1015,
	1016,
	1017,
	1018,
	1019,
	1020,
	1021,
	1022,
	-1
	-1,
	-1,
	-1,
	1024,
	1025,
	1026,
	1027,
	1028,
	1029,
	1030,
	1031,
	1032,
	1033,
	1034
];

PIANO_keySoundMap = [
	"C3",
	"Csh3",
	"D3",
	"Dsh3",
	"E3",
	"F3",
	"Fsh3",
	"G3",
	"Gsh3",
	"A3",
	"Ash3",
	"B3",
	"C4",
	"Csh4",
	"D4",
	"Dsh4",
	"E4",
	"F4",
	"Fsh4",
	"G4",
	"Gsh4",
	"A4",
	"Ash4",
	"B4",
	"C5",
	"Csh5",
	"D5",
	"Dsh5",
	"E5",
	"F5",
	"Fsh5",
	"G5",
	"Gsh5",
	"A5",
	"Ash5",
	"B5"
];

PIANO_soundObjects = [];
PIANO_keyOriginalColorMap = [];

PIANO_keyDownHandlerId = -1;
PIANO_keyUpHandlerId = -1;

PIANO_fnc_keyDownHandler = {
	_keyCode = _this select 1;

	if (_keyCode == 1) exitWith {
		(findDisplay 46) displayRemoveEventHandler ["KeyDown", PIANO_keyDownHandlerId];
		(findDisplay 46) displayRemoveEventHandler ["KeyUp", PIANO_keyUpHandlerId];
		closeDialog 0;
		true
	};

	if (_keyCode < count PIANO_keyControlMap) then {
		_idc = PIANO_keyControlMap select _keyCode;

		if (_idc != -1) exitWith {
			_keyIndex = _idc - 1000;

			if (isNull(PIANO_soundObjects select _keyIndex)) then {
				ctrlSetText [_idc, "#(argb,8,8,3)color(1,0,0,1)"];
				//_obj = playSound (PIANO_keySoundMap select _keyIndex);
				_obj = "Land_HelipadEmpty_F" createVehicle (getPos player);
				_obj say [PIANO_keySoundMap select _keyIndex, 100];
				PIANO_soundObjects set [_keyIndex, _obj];
			};

			true
		};
	};

	false
};

PIANO_fnc_keyUpHandler = {
	_keyCode = _this select 1;

	if (_keyCode < count PIANO_keyControlMap) then {
		_idc = PIANO_keyControlMap select _keyCode;

		if (_idc != -1) exitWith {
			_keyIndex = _idc - 1000;
			ctrlSetText [_idc, PIANO_keyOriginalColorMap select _keyIndex];

			(PIANO_soundObjects select _keyIndex) spawn {
				sleep 0.1;
				deleteVehicle _this;
			};

			PIANO_soundObjects set [_keyIndex, objNull];
			true
		};
	};

	false
};

PIANO_fnc_init = {
	for "_i" from 0 to 35 do {
		PIANO_keyOriginalColorMap pushBack (ctrlText (1000 + _i));
		PIANO_soundObjects pushBack objNull;
	};
};

PIANO_fnc_open = {
	createDialog "piano";

	// @TODO: Temporary hack.
	[] call PIANO_fnc_init;

	waitUntil {!isNull (findDisplay 46)};
	PIANO_keyDownHandlerId = (findDisplay 46) displayAddEventHandler ["KeyDown", "_this call PIANO_fnc_keyDownHandler"];
	PIANO_keyUpHandlerId = (findDisplay 46) displayAddEventHandler ["KeyUp", "_this call PIANO_fnc_keyUpHandler"];
};

