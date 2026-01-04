import { useNuiEvent } from "@/hooks/useNuiEvent";
import { MinimapStateInterface, useMinimapStateStore } from "@/states/minimap";
import { PlayerStateInterface, usePlayerStateStore } from "@/states/player";
import React, { useCallback, useMemo } from "preact/compat";
import { BiSolidShieldAlt2 } from "react-icons/bi";
import { FaGlassWater, FaBurger, FaBrain, FaMicrophone, FaPersonSwimming, FaPersonRunning } from "react-icons/fa6";
import { TiHeartFullOutline } from "react-icons/ti";
import { StatBar, StatBarSegmented } from "./ui/status-bars";
import { useSkewedStyle, useSkewAmount } from "@/states/skewed-style";

const PlayerStatus = () => {
  const [playerState, setPlayerState] = usePlayerStateStore();
  const [minimap, setMinimapState] = useMinimapStateStore();
  const skewedStyle = useSkewedStyle();
  const skewedAmount = useSkewAmount();

  const handlePlayerStateUpdate = useCallback(
    (newState: PlayerStateInterface) => {
      setPlayerState((prevState) => {
        if (JSON.stringify(prevState) !== JSON.stringify(newState)) {
          return newState;
        }
        return prevState;
      });
    },
    [setPlayerState],
  );

  useNuiEvent<{ minimap: MinimapStateInterface; player: PlayerStateInterface }>("state::global::set", (data) => {
    handlePlayerStateUpdate(data.player);
    setMinimapState(data.minimap);
  });

  const isUsingFramework = useMemo(() => {
    return playerState.hunger !== undefined || playerState.thirst !== undefined;
  }, [playerState]);

  const bottomOffset = useMemo(() => {
    const offset = window.innerHeight - minimap.top - minimap.height;
    return Math.max(32, offset);
  }, [minimap]);

  return (
    <>
      <div
        class="absolute items-end justify-center z-20 flex"
        style={{
          bottom: bottomOffset + "px",
          left: minimap.left + "px",
          width: minimap.width * 2 + "px",
          height: minimap.height + "px",
        }}
      >
        <div
          className="w-full h-full relative"
          style={skewedStyle ? {
            transform: `perspective(1000px) rotateY(${skewedAmount}deg)`,
            backfaceVisibility: "hidden",
            transformStyle: "preserve-3d",
            willChange: "transform",
          } : undefined}
        >
          <div className={"absolute -bottom-12 w-full flex gap-3 items-center justify-start"}>
            <div className={"flex flex-col w-2/4 items-center justify-center gap-1"}>
              <StatBarSegmented Icon={BiSolidShieldAlt2} value={playerState.armor} color="#2B78FC" />
              <StatBar Icon={TiHeartFullOutline} value={playerState.health} color="#06CE6B" maxValue={100} />
            </div>
            {isUsingFramework && (
              <>
                <div className="w-2/4 flex gap-3">
                  {typeof playerState.mic === "boolean" && playerState.mic === true ? <StatBar Icon={FaMicrophone} value={playerState.mic ? 100 : 0} color="#FFFF00" vertical /> : typeof playerState.voice === "number" ? <StatBar Icon={FaMicrophone} value={playerState.voice} color="#ffffff" vertical /> : null}

                  <StatBar Icon={FaBurger} value={playerState.hunger} color="#FB8607" vertical />
                  <StatBar Icon={FaGlassWater} value={playerState.thirst} color="#2B78FC" vertical />
                  {playerState.oxygen < 100 && (
                  <StatBar
                    Icon={FaPersonSwimming}
                    value={playerState.oxygen}
                    color="#00d4ff"
                    vertical
                  />
                )}
                {playerState.stamina < 100 && (
                  <StatBar
                    Icon={FaPersonRunning}
                    value={playerState.stamina}
                    color="#63e6be"
                    vertical
                  />
                )}
                  {typeof playerState.stress === "number" && playerState.stress > 0 && <StatBar Icon={FaBrain} value={playerState.stress} color="#FE2436" vertical />}
                </div>
              </>
            )}
          </div>
        </div>
      </div>
    </>
  );
};

export default React.memo(PlayerStatus);
