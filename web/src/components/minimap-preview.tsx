import { FunctionalComponent, h } from "preact";
import { useState, useEffect } from "preact/hooks";
import { useMinimapState } from "../states/minimap";
import { isEnvBrowser } from "../utils/misc";

const MinimapPreview: FunctionalComponent = () => {
  const minimap = useMinimapState();
  const [viewportHeight, setViewportHeight] = useState(typeof window !== 'undefined' ? window.innerHeight : 800);

  useEffect(() => {
    const handleResize = () => setViewportHeight(window.innerHeight);
    window.addEventListener('resize', handleResize);
    return () => window.removeEventListener('resize', handleResize);
  }, []);

  if (!isEnvBrowser()) return null;

  const rawBottom = viewportHeight - minimap.top - minimap.height;
  const bottomOffset = Math.max(32, rawBottom);
  const leftOffset = minimap.left;

  const style: any = {
    position: "fixed",
    left: `${leftOffset}px`,
    bottom: `${bottomOffset}px`,
    width: `${minimap.width}px`,
    height: `${minimap.height}px`,
    background: "rgba(0,0,0,0.25)",
    border: "2px dashed rgba(255,255,255,0.6)",
    borderRadius: "4px",
    zIndex: 9999,
    pointerEvents: "none",
  };

  return <div style={style} />;
};

export default MinimapPreview;
