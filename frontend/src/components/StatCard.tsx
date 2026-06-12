import React from "react";
import { View, Text, StyleSheet } from "react-native";
import { SHADOW_CARD } from "@/src/constants/theme";

type Props = {
  title: string;
  value: string;
  subtitle?: string;
  color: string;
  icon: React.ReactNode;
  testID?: string;
};

export function StatCard({ title, value, subtitle, color, icon, testID }: Props) {
  return (
    <View
      style={[styles.card, { backgroundColor: color }, SHADOW_CARD]}
      testID={testID}
      // @ts-ignore
      data-testid={testID}
    >
      <View style={styles.iconWrap}>{icon}</View>
      <View style={styles.body}>
        <Text style={styles.title}>{title}</Text>
        <Text style={styles.value}>{value}</Text>
        {subtitle ? <Text style={styles.subtitle}>{subtitle}</Text> : null}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  card: {
    borderRadius: 18,
    paddingVertical: 18,
    paddingHorizontal: 18,
    flexDirection: "row",
    alignItems: "center",
    gap: 16,
  },
  iconWrap: {
    width: 52,
    height: 52,
    borderRadius: 16,
    backgroundColor: "rgba(255,255,255,0.22)",
    alignItems: "center",
    justifyContent: "center",
  },
  body: { flex: 1 },
  title: {
    color: "#FFFFFFEE",
    fontSize: 13,
    fontWeight: "600",
    letterSpacing: 0.3,
  },
  value: {
    color: "#FFFFFF",
    fontSize: 24,
    fontWeight: "800",
    marginTop: 2,
    letterSpacing: -0.5,
  },
  subtitle: {
    color: "#FFFFFFCC",
    fontSize: 12,
    marginTop: 2,
  },
});
