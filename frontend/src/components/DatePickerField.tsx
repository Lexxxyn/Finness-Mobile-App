import React, { useState } from "react";
import { View, Text, StyleSheet, TouchableOpacity, Platform } from "react-native";
import { Calendar as CalendarIcon } from "lucide-react-native";
import DateTimePicker, { DateTimePickerAndroid } from "@react-native-community/datetimepicker";
import { COLORS } from "@/src/constants/theme";

type Props = {
  label?: string;
  value: string; // formatted display value, e.g. "Mar 5, 1996"
  onChange: (val: string, date: Date) => void;
  testID?: string;
  placeholder?: string;
};

function formatDate(d: Date): string {
  return d.toLocaleDateString("en-US", { year: "numeric", month: "short", day: "numeric" });
}

function parseDate(value: string): Date {
  const d = value ? new Date(value) : new Date(1996, 0, 1);
  return isNaN(d.getTime()) ? new Date(1996, 0, 1) : d;
}

export function DatePickerField({ label, value, onChange, testID, placeholder }: Props) {
  const [iosOpen, setIosOpen] = useState(false);
  const current = parseDate(value);

  const openAndroid = () => {
    DateTimePickerAndroid.open({
      value: current,
      mode: "date",
      display: "calendar",
      maximumDate: new Date(),
      onChange: (_event, selected) => {
        if (selected) onChange(formatDate(selected), selected);
      },
    });
  };

  const handlePress = () => {
    if (Platform.OS === "android") openAndroid();
    else setIosOpen(true);
  };

  return (
    <View style={styles.wrap}>
      {label ? <Text style={styles.label}>{label}</Text> : null}
      <TouchableOpacity
        activeOpacity={0.85}
        onPress={handlePress}
        style={styles.row}
        testID={testID}
        // @ts-ignore
        data-testid={testID}
      >
        <View style={styles.icon}>
          <CalendarIcon color={COLORS.text.tertiary} size={18} />
        </View>
        <Text style={[styles.value, !value && styles.placeholder]}>
          {value || placeholder || "Pick a date"}
        </Text>
      </TouchableOpacity>

      {Platform.OS === "ios" && iosOpen ? (
        <View style={{ marginTop: 4 }}>
          <DateTimePicker
            value={current}
            mode="date"
            display="spinner"
            maximumDate={new Date()}
            onChange={(_e, selected) => {
              if (selected) onChange(formatDate(selected), selected);
            }}
          />
          <TouchableOpacity onPress={() => setIosOpen(false)} style={styles.iosDone}>
            <Text style={styles.iosDoneText}>Done</Text>
          </TouchableOpacity>
        </View>
      ) : null}
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
  icon: { paddingLeft: 14, paddingRight: 6 },
  value: { flex: 1, paddingVertical: 14, paddingRight: 14, fontSize: 15, color: COLORS.text.primary },
  placeholder: { color: COLORS.text.tertiary },
  iosDone: {
    alignSelf: "flex-end",
    paddingHorizontal: 14,
    paddingVertical: 8,
    backgroundColor: COLORS.primary,
    borderRadius: 18,
    marginTop: 6,
  },
  iosDoneText: { color: "#FFFFFF", fontWeight: "700", fontSize: 13 },
});
