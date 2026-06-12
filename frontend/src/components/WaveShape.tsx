import React from "react";
import Svg, { Path } from "react-native-svg";

type Props = {
  color?: string;
  width?: number;
  height?: number;
};

export function WaveShape({ color = "#FFFFFF55", width = 400, height = 120 }: Props) {
  return (
    <Svg width={width} height={height} viewBox="0 0 400 120" preserveAspectRatio="none">
      <Path
        d="M0,60 C80,100 160,20 240,60 C320,100 400,40 400,40 L400,120 L0,120 Z"
        fill={color}
      />
      <Path
        d="M0,80 C80,40 160,100 240,70 C320,40 400,80 400,80 L400,120 L0,120 Z"
        fill="#FFFFFF66"
      />
    </Svg>
  );
}
