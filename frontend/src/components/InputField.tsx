import React from "react";
import { View, Text, TextInput, StyleSheet, TextInputProps } from "react-native";
import { COLORS } from "@/src/constants/theme";

type Props = TextInputProps & {
  label?: string;
  icon?: React.ReactNode;
  rightElement?: React.ReactNode;
  testID?: string;
};

export function InputField({ label, icon, rightElement, testID, style, ...rest }: Props) {
  return (
    <View style={styles.wrap}>
      {label ? <Text style={styles.label}>{label}</Text> : null}
      <View style={styles.row}>
        {icon ? <View style={styles.icon}>{icon}</View> : null}
        <TextInput
          {...rest}
          testID={testID}
          // @ts-ignore web
          data-testid={testID}
          placeholderTextColor={COLORS.text.tertiary}
          style={[styles.input, !icon && { paddingLeft: 16 }, style]}
        />
        {rightElement}
      </View>
    </View>
  );
}

const styles = StyleSheet.create({
  wrap: { marginBottom: 12 },
  label: {
    fontSize: 13,
    fontWeight: "600",
    color: COLORS.text.secondary,
    marginBottom: 6,
  },
  row: {
    flexDirection: "row",
    alignItems: "center",
    backgroundColor: "#F3F6FA",
    borderRadius: 14,
    borderWidth: 1,
    borderColor: "#E5E7EB",
    minHeight: 50,
  },
  icon: {
    paddingLeft: 14,
    paddingRight: 6,
  },
  input: {
    flex: 1,
    paddingVertical: 12,
    paddingRight: 14,
    fontSize: 15,
    color: COLORS.text.primary,
  },
});
