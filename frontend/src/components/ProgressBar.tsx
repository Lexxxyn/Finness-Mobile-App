import React from "react";
import { View, StyleSheet } from "react-native";
import { COLORS } from "@/src/constants/theme";

type Props = {
  value: number; // 0..1
  color?: string;
  trackColor?: string;
  height?: number;
};

export function ProgressBar({
  value,
  color = COLORS.primary,
  trackColor = "#E5E7EB",
  height = 8,
}: Props) {
  const clamped = Math.max(0, Math.min(1, value));
  return (
    <View
      style={[styles.track, { backgroundColor: trackColor, height, borderRadius: height / 2 }]}
    >
      <View
        style={{
          width: `${clamped * 100}%`,
          height: "100%",
          backgroundColor: color,
          borderRadius: height / 2,
        }}
      />
    </View>
  );
}

const styles = StyleSheet.create({
  track: {
    width: "100%",
    overflow: "hidden",
  },
});
