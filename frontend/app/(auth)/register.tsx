import React, { useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  KeyboardAvoidingView,
  Platform,
  ScrollView,
  TouchableOpacity,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { Heart, Mail, Lock, User } from "lucide-react-native";
import { Link, useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { InputField } from "@/src/components/InputField";
import { useAuth } from "@/src/context/AuthContext";

const ACCENT = COLORS.cta.registerAccent;

export default function Register() {
  const router = useRouter();
  const { register } = useAuth();
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const submit = async () => {
    setErrorMsg(null);
    if (!name || !email || !password) {
      setErrorMsg("Please fill in all fields.");
      return;
    }
    if (password.length < 6) {
      setErrorMsg("Password must be at least 6 characters.");
      return;
    }
    if (password !== confirm) {
      setErrorMsg("Passwords do not match.");
      return;
    }
    setLoading(true);
    try {
      await register(name, email, password);
      router.replace("/(tabs)/home");
    } catch (e: any) {
      setErrorMsg(e?.message ?? "Registration failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.safe} edges={["top", "bottom"]}>
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : undefined}
        style={{ flex: 1 }}
      >
        <ScrollView
          contentContainerStyle={styles.scroll}
          keyboardShouldPersistTaps="handled"
        >
          <View style={[styles.iconCircle, { backgroundColor: ACCENT }]}>
            <Heart color="#FFFFFF" size={36} strokeWidth={2.5} fill="#FFFFFF55" />
          </View>
          <Text style={styles.title}>Create Account</Text>
          <Text style={styles.subtitle}>Start your wellness journey today</Text>

          <View style={[styles.card, SHADOW_CARD]}>
            <InputField
              label="Full Name"
              icon={<User color={COLORS.text.tertiary} size={18} />}
              placeholder="Jane Doe"
              value={name}
              onChangeText={setName}
              testID="register-name-input"
            />
            <InputField
              label="Email"
              icon={<Mail color={COLORS.text.tertiary} size={18} />}
              placeholder="your.email@example.com"
              autoCapitalize="none"
              keyboardType="email-address"
              value={email}
              onChangeText={setEmail}
              testID="register-email-input"
            />
            <InputField
              label="Password"
              icon={<Lock color={COLORS.text.tertiary} size={18} />}
              placeholder="Create a password"
              secureTextEntry
              value={password}
              onChangeText={setPassword}
              testID="register-password-input"
            />
            <InputField
              label="Confirm Password"
              icon={<Lock color={COLORS.text.tertiary} size={18} />}
              placeholder="Re-enter password"
              secureTextEntry
              value={confirm}
              onChangeText={setConfirm}
              testID="register-confirm-input"
            />

            {errorMsg ? <Text style={styles.error}>{errorMsg}</Text> : null}

            <PrimaryButton
              label="Register"
              color={ACCENT}
              onPress={submit}
              loading={loading}
              testID="register-submit-button"
            />
          </View>

          <View style={styles.footerRow}>
            <Text style={styles.footerText}>Already have an account?</Text>
            <Link href="/(auth)/login" asChild>
              <TouchableOpacity testID="register-go-login" /* @ts-ignore */ data-testid="register-go-login">
                <Text style={[styles.link, { color: ACCENT }]}>Login</Text>
              </TouchableOpacity>
            </Link>
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  scroll: { flexGrow: 1, paddingHorizontal: 24, paddingVertical: 24 },
  iconCircle: {
    width: 84,
    height: 84,
    borderRadius: 42,
    alignSelf: "center",
    alignItems: "center",
    justifyContent: "center",
    marginTop: 8,
    marginBottom: 16,
    ...SHADOW_CARD,
  },
  title: {
    fontSize: 28,
    fontWeight: "800",
    color: COLORS.text.primary,
    textAlign: "center",
    letterSpacing: -0.6,
  },
  subtitle: {
    fontSize: 14,
    color: COLORS.text.tertiary,
    textAlign: "center",
    marginTop: 6,
    marginBottom: 24,
  },
  card: { backgroundColor: COLORS.card, borderRadius: 20, padding: 20 },
  error: { color: "#DC2626", fontSize: 13, marginBottom: 10, textAlign: "center" },
  footerRow: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    marginTop: 18,
    gap: 6,
  },
  footerText: { color: COLORS.text.secondary, fontSize: 14 },
  link: { fontWeight: "700", fontSize: 14 },
});
