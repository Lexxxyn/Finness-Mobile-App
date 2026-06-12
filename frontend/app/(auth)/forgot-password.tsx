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
import { KeyRound, Mail, ArrowLeft } from "lucide-react-native";
import { useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { InputField } from "@/src/components/InputField";
import { useAuth } from "@/src/context/AuthContext";

export default function ForgotPassword() {
  const router = useRouter();
  const { resetPassword } = useAuth();
  const [email, setEmail] = useState("");
  const [loading, setLoading] = useState(false);
  const [message, setMessage] = useState<{ ok: boolean; text: string } | null>(null);

  const submit = async () => {
    setMessage(null);
    if (!email) {
      setMessage({ ok: false, text: "Please enter your email." });
      return;
    }
    setLoading(true);
    try {
      await resetPassword(email);
      setMessage({ ok: true, text: "Reset link sent! Check your email inbox." });
    } catch (e: any) {
      setMessage({ ok: false, text: e?.message ?? "Could not send reset email." });
    } finally {
      setLoading(false);
    }
  };

  return (
    <SafeAreaView style={styles.safe} edges={["top", "bottom"]}>
      <KeyboardAvoidingView behavior={Platform.OS === "ios" ? "padding" : undefined} style={{ flex: 1 }}>
        <ScrollView
          contentContainerStyle={styles.scroll}
          keyboardShouldPersistTaps="handled"
        >
          <View style={styles.iconCircle}>
            <KeyRound color="#FFFFFF" size={32} strokeWidth={2.5} />
          </View>
          <Text style={styles.title}>Forgot Password?</Text>
          <Text style={styles.subtitle}>
            Enter your email below and we&apos;ll send you a link to reset your password.
          </Text>

          <View style={[styles.card, SHADOW_CARD]}>
            <InputField
              label="Email"
              icon={<Mail color={COLORS.text.tertiary} size={18} />}
              placeholder="your.email@example.com"
              autoCapitalize="none"
              keyboardType="email-address"
              value={email}
              onChangeText={setEmail}
              testID="forgot-email-input"
            />
            {message ? (
              <Text style={[styles.msg, { color: message.ok ? "#16A34A" : "#DC2626" }]}>
                {message.text}
              </Text>
            ) : null}
            <PrimaryButton
              label="Send Reset Link"
              onPress={submit}
              loading={loading}
              testID="forgot-submit-button"
            />
          </View>

          <TouchableOpacity
            onPress={() => router.back()}
            style={styles.back}
            testID="forgot-back-button"
            // @ts-ignore
            data-testid="forgot-back-button"
          >
            <ArrowLeft color={COLORS.primary} size={16} />
            <Text style={styles.backText}>Back to Login</Text>
          </TouchableOpacity>
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
    backgroundColor: COLORS.primary,
    alignSelf: "center",
    alignItems: "center",
    justifyContent: "center",
    marginTop: 24,
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
    marginTop: 8,
    marginBottom: 24,
    paddingHorizontal: 8,
  },
  card: { backgroundColor: COLORS.card, borderRadius: 20, padding: 20 },
  msg: { textAlign: "center", marginBottom: 10, fontSize: 13 },
  back: {
    flexDirection: "row",
    alignItems: "center",
    justifyContent: "center",
    gap: 6,
    marginTop: 20,
  },
  backText: { color: COLORS.primary, fontWeight: "700", fontSize: 14 },
});
