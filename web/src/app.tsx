import { useNuiEvent } from "@/hooks/useNuiEvent.ts";
import { useEffect, useState } from "react";
import CarHud from "./components/car-hud";
import Compass from "./components/compass";
import PlayerStatus from "./components/player-status";
import MinimapPreview from "./components/minimap-preview";
import { useSetMinimapState, type MinimapStateInterface } from "./states/minimap";
import type { ConfigInterface } from "./types/config";
import { debug, setDebugMode } from "./utils/debug";
import { fetchNui } from "./utils/fetchNui";
import { isEnvBrowser } from "./utils/misc";
import { useCompassLocationStore, useCompassAlwaysStore } from "./states/compass-location";
import { useSkewedStyleStore, useSkewAmountStore } from "@/states/skewed-style";

if (isEnvBrowser()) {
  const body = document.body;
  body!.style.backgroundImage = 'url("https://images.hdqwalls.com/download/dodge-charger-srt-hellcat-enforcer-n1-3840x2400.jpg")';
  body!.style.backgroundSize = "cover";
  body!.style.backgroundRepeat = "no-repeat";
  debug("App loaded in browser");
}

export function App() {
  const [visible, setVisible] = useState(true);
  const setMinimapState = useSetMinimapState();
  const [compassLocation, setCompassLocation] = useCompassLocationStore();
  const [compassAlways, setCompassAlways] = useCompassAlwaysStore();
  const [skewedStyle, setSkewedStyle] = useSkewedStyleStore();
  const [skewAmount, setSkewAmount] = useSkewAmountStore();

  useNuiEvent("state::visibility::app::set", (state) => {
    const newState = state === "toggle" ? !visible : state;
    setVisible(newState);

    fetchNui("state::visibility::app::sync", newState);

    debug(`(App) NUI message received: setVisible ${state}`, `newState: ${newState}`);
  });

  useEffect(() => {
    fetchNui("APP_LOADED")
      .then((res: { config: ConfigInterface; minimap: MinimapStateInterface }) => {
        setDebugMode(res.config.debug ?? false);
        setMinimapState(res.minimap);
        setCompassLocation(res.config.compassLocation);
        setCompassAlways(res.config.compassAlways);
        setSkewedStyle(res.config.useSkewedStyle);
        setSkewAmount(res.config.skewAmount);
      })
      .catch((err) => {
        console.error(err);
      })
      .finally(() => {
        debug("(App) fetched uiLoaded callback");
      });
  }, []);

  if (!visible) {
    debug("(App) Returning with no children since the app is not visible.");
    return <></>;
  }

  return (
    <>
      <MinimapPreview />
      <PlayerStatus />
      <CarHud />

      {compassLocation !== "hidden" && (
        <>
          <Compass />
        </>
      )}
    </>
  );
}
