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
import { Heart, Mail, Lock, Eye, EyeOff } from "lucide-react-native";
import { Link, useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { InputField } from "@/src/components/InputField";
import { useAuth } from "@/src/context/AuthContext";

export default function Login() {
  const router = useRouter();
  const { signIn } = useAuth();
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [showPassword, setShowPassword] = useState(false);
  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const submit = async () => {
    setErrorMsg(null);
    if (!email || !password) {
      setErrorMsg("Please enter your email and password.");
      return;
    }
    setLoading(true);
    try {
      await signIn(email, password);
      router.replace("/(tabs)/home");
    } catch (e: any) {
      setErrorMsg(e?.message ?? "Login failed. Please try again.");
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
          <View style={styles.iconCircle}>
            <Heart color="#FFFFFF" size={36} strokeWidth={2.5} fill="#FFFFFF55" />
          </View>
          <Text style={styles.title}>Welcome Back</Text>
          <Text style={styles.subtitle}>Login to continue your wellness journey</Text>

          <View style={[styles.card, SHADOW_CARD]}>
            <InputField
              label="Email"
              icon={<Mail color={COLORS.text.tertiary} size={18} />}
              placeholder="your.email@example.com"
              autoCapitalize="none"
              keyboardType="email-address"
              value={email}
              onChangeText={setEmail}
              testID="login-email-input"
            />
            <InputField
              label="Password"
              icon={<Lock color={COLORS.text.tertiary} size={18} />}
              placeholder="Enter your password"
              secureTextEntry={!showPassword}
              value={password}
              onChangeText={setPassword}
              testID="login-password-input"
              rightElement={
                <TouchableOpacity
                  onPress={() => setShowPassword((v) => !v)}
                  style={styles.eyeBtn}
                  testID="login-toggle-password"
                  // @ts-ignore
                  data-testid="login-toggle-password"
                >
                  {showPassword ? (
                    <EyeOff color={COLORS.text.tertiary} size={18} />
                  ) : (
                    <Eye color={COLORS.text.tertiary} size={18} />
                  )}
                </TouchableOpacity>
              }
            />
            <TouchableOpacity
              onPress={() => router.push("/(auth)/forgot-password")}
              style={styles.forgot}
              testID="login-forgot-link"
              // @ts-ignore
              data-testid="login-forgot-link"
            >
              <Text style={styles.forgotText}>Forgot Password?</Text>
            </TouchableOpacity>

            {errorMsg ? <Text style={styles.error}>{errorMsg}</Text> : null}

            <PrimaryButton
              label="Login"
              onPress={submit}
              loading={loading}
              testID="login-submit-button"
            />
          </View>

          <View style={styles.footerRow}>
            <Text style={styles.footerText}>Don&apos;t have an account?</Text>
            <Link href="/(auth)/register" asChild>
              <TouchableOpacity testID="login-go-register" /* @ts-ignore */ data-testid="login-go-register">
                <Text style={styles.signupLink}>Sign Up</Text>
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
  scroll: {
    flexGrow: 1,
    paddingHorizontal: 24,
    paddingVertical: 24,
    alignItems: "stretch",
  },
  iconCircle: {
    width: 84,
    height: 84,
    borderRadius: 42,
    backgroundColor: COLORS.primary,
    alignSelf: "center",
    alignItems: "center",
    justifyContent: "center",
    marginTop: 16,
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
  forgot: { alignSelf: "flex-end", paddingVertical: 6, marginBottom: 8 },
  forgotText: { color: COLORS.primary, fontWeight: "700", fontSize: 13 },
  eyeBtn: { paddingHorizontal: 14, paddingVertical: 12 },
  error: { color: "#DC2626", fontSize: 13, marginBottom: 10, textAlign: "center" },
  footerRow: {
    flexDirection: "row",
    justifyContent: "center",
    alignItems: "center",
    marginTop: 18,
    gap: 6,
  },
  footerText: { color: COLORS.text.secondary, fontSize: 14 },
  signupLink: { color: COLORS.primary, fontWeight: "700", fontSize: 14 },
});
