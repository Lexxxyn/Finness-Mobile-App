import React from "react";
import { TouchableOpacity, Text, StyleSheet, ActivityIndicator, ViewStyle, TextStyle } from "react-native";
import { COLORS, SHADOW_BUTTON } from "@/src/constants/theme";

type Props = {
  label: string;
  onPress?: () => void;
  color?: string;
  textColor?: string;
  loading?: boolean;
  disabled?: boolean;
  testID?: string;
  style?: ViewStyle;
  textStyle?: TextStyle;
  icon?: React.ReactNode;
};

export function PrimaryButton({
  label,
  onPress,
  color = COLORS.primary,
  textColor = "#FFFFFF",
  loading,
  disabled,
  testID,
  style,
  textStyle,
  icon,
}: Props) {
  return (
    <TouchableOpacity
      activeOpacity={0.85}
      onPress={onPress}
      disabled={disabled || loading}
      testID={testID}
      // @ts-ignore web data attr
      data-testid={testID}
      style={[
        styles.btn,
        { backgroundColor: color, opacity: disabled ? 0.55 : 1 },
        SHADOW_BUTTON,
        style,
      ]}
    >
      {loading ? (
        <ActivityIndicator color={textColor} />
      ) : (
        <>
          {icon}
          <Text style={[styles.label, { color: textColor }, textStyle]}>{label}</Text>
        </>
      )}
    </TouchableOpacity>
  );
}

const styles = StyleSheet.create({
  btn: {
    borderRadius: 24,
    paddingVertical: 14,
    paddingHorizontal: 24,
    alignItems: "center",
    justifyContent: "center",
    flexDirection: "row",
    gap: 8,
  },
  label: {
    fontSize: 16,
    fontWeight: "700",
    letterSpacing: -0.2,
  },
});
