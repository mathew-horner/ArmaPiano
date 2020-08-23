class PlaybackMenu
{
    idd = 1999;

    class controlsBackground
    {
        class Background: IGUIBack
        {
            idc = -1;
            x = 0.4175 * safezoneW + safezoneX;
            y = 0.302 * safezoneH + safezoneY;
            w = 0.165 * safezoneW;
            h = 0.363 * safezoneH;
			colorbackground[] = { 0, 0, 0, 0.6 };
        };
    };

    class controls
    {
        class RecordingList: RscListbox
        {
            idc = 1100;
            x = 0.422656 * safezoneW + safezoneX;
            y = 0.313 * safezoneH + safezoneY;
            w = 0.154687 * safezoneW;
            h = 0.319 * safezoneH;
        };

        class SelectButton: RscButton
        {
            idc = -1;
            text = "Select"; //--- ToDo: Localize;
            x = 0.422656 * safezoneW + safezoneX;
            y = 0.6386 * safezoneH + safezoneY;
            w = 0.0495 * safezoneW;
            h = 0.022 * safezoneH;
        };

        class DeleteButton: RscButton
        {
            idc = -1;
            text = "Delete"; //--- ToDo: Localize;
            x = 0.47422 * safezoneW + safezoneX;
            y = 0.6386 * safezoneH + safezoneY;
            w = 0.0495 * safezoneW;
            h = 0.022 * safezoneH;
        };

        class CancelButton: RscButton
        {
            idc = -1;
            text = "Cancel"; //--- ToDo: Localize;
            x = 0.526812 * safezoneW + safezoneX;
            y = 0.6386 * safezoneH + safezoneY;
            w = 0.0505312 * safezoneW;
            h = 0.022 * safezoneH;
			action = "closeDialog 1999";
        };
    };
};
