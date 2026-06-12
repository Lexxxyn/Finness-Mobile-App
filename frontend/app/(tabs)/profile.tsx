import React from "react";
import { View, Text, StyleSheet, ScrollView, TouchableOpacity } from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import {
  User as UserIcon,
  Calendar,
  Ruler,
  Scale,
  Bell,
  Lock,
  HelpCircle,
  ChevronRight,
  LogOut,
} from "lucide-react-native";
import { useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";

type Row = {
  key: string;
  label: string;
  value: string;
  Icon: any;
};

export default function ProfileScreen() {
  const router = useRouter();
  const { user, profile, logout } = useAuth();

  const rows: Row[] = [
    { key: "gender", label: "Gender", value: profile?.gender ?? "—", Icon: UserIcon },
    { key: "dob", label: "Date of Birth", value: profile?.dob ?? "—", Icon: Calendar },
    {
      key: "height",
      label: "Height",
      value: profile?.height ? `${profile.height} cm` : "—",
      Icon: Ruler,
    },
    {
      key: "weight",
      label: "Weight",
      value: profile?.weight ? `${profile.weight} kg` : "—",
      Icon: Scale,
    },
  ];

  const onLogout = async () => {
    try {
      await logout();
    } finally {
      router.replace("/(auth)/login");
    }
  };

  return (
    <SafeAreaView style={styles.safe} edges={["top"]}>
      <ScrollView contentContainerStyle={styles.scroll} showsVerticalScrollIndicator={false}>
        <Text style={styles.title}>Profile</Text>
        <Text style={styles.subtitle}>Manage your account</Text>

        <View style={styles.avatarWrap}>
          <View style={styles.avatar} testID="profile-avatar">
            <UserIcon color="#FFFFFF" size={48} strokeWidth={2.5} />
          </View>
          <Text style={styles.name} testID="profile-name">
            {profile?.name ?? user?.displayName ?? "User"}
          </Text>
          <Text style={styles.email}>{user?.email}</Text>
        </View>

        <View style={{ gap: 10, marginTop: 18 }}>
          {rows.map(({ key, label, value, Icon }) => (
            <View key={key} style={[styles.row, SHADOW_CARD]} testID={`profile-row-${key}`}>
              <View style={styles.rowIcon}>
                <Icon color={COLORS.profile.avatar} size={18} strokeWidth={2.5} />
              </View>
              <View style={{ flex: 1 }}>
                <Text style={styles.rowLabel}>{label}</Text>
                <Text style={styles.rowValue}>{value}</Text>
              </View>
              <ChevronRight color={COLORS.text.tertiary} size={18} strokeWidth={2.5} />
            </View>
          ))}
        </View>

        <View style={[styles.prefCard, SHADOW_CARD]}>
          <Text style={styles.prefTitle}>Preferences</Text>
          {[
            { key: "notif", label: "Notifications", Icon: Bell },
            { key: "privacy", label: "Privacy Settings", Icon: Lock },
            { key: "help", label: "Help & Support", Icon: HelpCircle },
          ].map((p, i, arr) => (
            <TouchableOpacity
              key={p.key}
              activeOpacity={0.7}
              style={[styles.prefRow, i < arr.length - 1 && styles.prefBorder]}
              testID={`profile-pref-${p.key}`}
              // @ts-ignore
              data-testid={`profile-pref-${p.key}`}
            >
              <p.Icon color={COLORS.text.secondary} size={18} strokeWidth={2.3} />
              <Text style={styles.prefLabel}>{p.label}</Text>
              <ChevronRight color={COLORS.text.tertiary} size={18} strokeWidth={2.5} />
            </TouchableOpacity>
          ))}
        </View>

        <View style={{ marginTop: 18 }}>
          <PrimaryButton
            label="Logout"
            color={COLORS.profile.logout}
            onPress={onLogout}
            icon={<LogOut color="#FFFFFF" size={18} strokeWidth={2.5} />}
            testID="profile-logout-button"
          />
        </View>
      </ScrollView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  scroll: { paddingHorizontal: 16, paddingVertical: 16, paddingBottom: 32 },
  title: { color: COLORS.text.primary, fontSize: 26, fontWeight: "800", letterSpacing: -0.6 },
  subtitle: { color: COLORS.text.tertiary, fontSize: 13, marginTop: 2 },
  avatarWrap: { alignItems: "center", marginTop: 18 },
  avatar: {
    width: 100,
    height: 100,
    borderRadius: 50,
    backgroundColor: COLORS.profile.avatar,
    alignItems: "center",
    justifyContent: "center",
    ...SHADOW_CARD,
  },
  name: { color: COLORS.text.primary, fontSize: 22, fontWeight: "800", marginTop: 12, letterSpacing: -0.4 },
  email: { color: COLORS.text.tertiary, fontSize: 13, marginTop: 2 },
  row: {
    backgroundColor: COLORS.card,
    borderRadius: 16,
    paddingVertical: 14,
    paddingHorizontal: 14,
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
  },
  rowIcon: {
    width: 38,
    height: 38,
    borderRadius: 12,
    backgroundColor: "#FBE3EE",
    alignItems: "center",
    justifyContent: "center",
  },
  rowLabel: { color: COLORS.text.tertiary, fontSize: 11, fontWeight: "700", letterSpacing: 0.8, textTransform: "uppercase" },
  rowValue: { color: COLORS.text.primary, fontSize: 16, fontWeight: "700", marginTop: 2 },
  prefCard: { marginTop: 18, backgroundColor: COLORS.card, borderRadius: 18, padding: 6, paddingTop: 14 },
  prefTitle: {
    color: COLORS.text.primary,
    fontSize: 16,
    fontWeight: "800",
    letterSpacing: -0.3,
    paddingHorizontal: 12,
    marginBottom: 6,
  },
  prefRow: {
    flexDirection: "row",
    alignItems: "center",
    gap: 12,
    paddingVertical: 14,
    paddingHorizontal: 12,
  },
  prefBorder: { borderBottomWidth: 1, borderBottomColor: "#F1F5F9" },
  prefLabel: { flex: 1, color: COLORS.text.primary, fontSize: 15, fontWeight: "600" },
});
