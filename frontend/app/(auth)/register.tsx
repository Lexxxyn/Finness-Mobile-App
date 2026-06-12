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
import {
  Heart,
  Mail,
  Lock,
  User,
  Eye,
  EyeOff,
  Calendar,
  Ruler,
  Scale,
  ChevronRight,
  ChevronLeft,
  Check,
} from "lucide-react-native";
import { Link, useRouter } from "expo-router";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { InputField } from "@/src/components/InputField";
import { useAuth } from "@/src/context/AuthContext";
import {
  EQUIPMENT_OPTIONS,
  GENDER_OPTIONS,
  type EquipmentId,
} from "@/src/constants/equipment";

const ACCENT = COLORS.cta.registerAccent;

type StepKey = "account" | "about" | "equipment";

export default function Register() {
  const router = useRouter();
  const { register } = useAuth();

  // Step state
  const [step, setStep] = useState<StepKey>("account");

  // Account
  const [name, setName] = useState("");
  const [email, setEmail] = useState("");
  const [password, setPassword] = useState("");
  const [confirm, setConfirm] = useState("");
  const [showPwd, setShowPwd] = useState(false);

  // About you
  const [gender, setGender] = useState<string>("Female");
  const [dob, setDob] = useState("");
  const [height, setHeight] = useState("165");
  const [weight, setWeight] = useState("58");

  // Equipment
  const [equipment, setEquipment] = useState<EquipmentId[]>(["bodyweight"]);

  const [loading, setLoading] = useState(false);
  const [errorMsg, setErrorMsg] = useState<string | null>(null);

  const validateStep1 = (): string | null => {
    if (!name.trim()) return "Please enter your full name.";
    if (!email.trim()) return "Please enter your email.";
    if (password.length < 6) return "Password must be at least 6 characters.";
    if (password !== confirm) return "Passwords do not match.";
    return null;
  };

  const validateStep2 = (): string | null => {
    if (!gender) return "Please select your gender.";
    const h = Number(height);
    const w = Number(weight);
    if (!h || h < 80 || h > 250) return "Please enter a valid height in cm.";
    if (!w || w < 25 || w > 250) return "Please enter a valid weight in kg.";
    return null;
  };

  const next = () => {
    setErrorMsg(null);
    if (step === "account") {
      const err = validateStep1();
      if (err) return setErrorMsg(err);
      setStep("about");
    } else if (step === "about") {
      const err = validateStep2();
      if (err) return setErrorMsg(err);
      setStep("equipment");
    }
  };

  const back = () => {
    setErrorMsg(null);
    if (step === "about") setStep("account");
    if (step === "equipment") setStep("about");
  };

  const toggleEquipment = (id: EquipmentId) => {
    setEquipment((prev) =>
      prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id],
    );
  };

  const submit = async () => {
    setErrorMsg(null);
    if (equipment.length === 0) {
      setErrorMsg("Pick at least one equipment option (Bodyweight is fine).");
      return;
    }
    setLoading(true);
    try {
      await register(name, email, password, {
        gender,
        dob: dob || undefined,
        height: Number(height),
        weight: Number(weight),
        equipment,
      });
      router.replace("/(tabs)/home");
    } catch (e: any) {
      setErrorMsg(e?.message ?? "Registration failed. Please try again.");
    } finally {
      setLoading(false);
    }
  };

  const stepIndex = step === "account" ? 0 : step === "about" ? 1 : 2;

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
            <Heart color="#FFFFFF" size={32} strokeWidth={2.5} fill="#FFFFFF55" />
          </View>
          <Text style={styles.title}>Create Account</Text>
          <Text style={styles.subtitle}>Start your wellness journey today</Text>

          {/* Stepper dots */}
          <View style={styles.dotsRow}>
            {[0, 1, 2].map((i) => (
              <View
                key={i}
                style={[
                  styles.dot,
                  i === stepIndex && { backgroundColor: ACCENT, width: 24 },
                ]}
              />
            ))}
          </View>

          <View style={[styles.card, SHADOW_CARD]}>
            {step === "account" && (
              <>
                <Text style={styles.stepTitle}>Account details</Text>
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
                  secureTextEntry={!showPwd}
                  value={password}
                  onChangeText={setPassword}
                  testID="register-password-input"
                  rightElement={
                    <TouchableOpacity
                      onPress={() => setShowPwd((v) => !v)}
                      style={styles.eyeBtn}
                      testID="register-toggle-password"
                      // @ts-ignore
                      data-testid="register-toggle-password"
                    >
                      {showPwd ? (
                        <EyeOff color={COLORS.text.tertiary} size={18} />
                      ) : (
                        <Eye color={COLORS.text.tertiary} size={18} />
                      )}
                    </TouchableOpacity>
                  }
                />
                <InputField
                  label="Confirm Password"
                  icon={<Lock color={COLORS.text.tertiary} size={18} />}
                  placeholder="Re-enter password"
                  secureTextEntry={!showPwd}
                  value={confirm}
                  onChangeText={setConfirm}
                  testID="register-confirm-input"
                />
              </>
            )}

            {step === "about" && (
              <>
                <Text style={styles.stepTitle}>About you</Text>
                <Text style={styles.fieldLabel}>Gender</Text>
                <View style={styles.chipRow}>
                  {GENDER_OPTIONS.map((g) => (
                    <TouchableOpacity
                      key={g}
                      onPress={() => setGender(g)}
                      style={[
                        styles.chip,
                        gender === g && {
                          backgroundColor: ACCENT,
                          borderColor: ACCENT,
                        },
                      ]}
                      testID={`register-gender-${g.toLowerCase()}`}
                      // @ts-ignore
                      data-testid={`register-gender-${g.toLowerCase()}`}
                    >
                      <Text
                        style={[
                          styles.chipText,
                          gender === g && { color: "#FFFFFF" },
                        ]}
                      >
                        {g}
                      </Text>
                    </TouchableOpacity>
                  ))}
                </View>

                <InputField
                  label="Date of Birth"
                  icon={<Calendar color={COLORS.text.tertiary} size={18} />}
                  placeholder="e.g. Jan 15, 1995"
                  value={dob}
                  onChangeText={setDob}
                  testID="register-dob-input"
                />
                <View style={{ flexDirection: "row", gap: 10 }}>
                  <View style={{ flex: 1 }}>
                    <InputField
                      label="Height (cm)"
                      icon={<Ruler color={COLORS.text.tertiary} size={18} />}
                      keyboardType="number-pad"
                      value={height}
                      onChangeText={setHeight}
                      testID="register-height-input"
                    />
                  </View>
                  <View style={{ flex: 1 }}>
                    <InputField
                      label="Weight (kg)"
                      icon={<Scale color={COLORS.text.tertiary} size={18} />}
                      keyboardType="decimal-pad"
                      value={weight}
                      onChangeText={setWeight}
                      testID="register-weight-input"
                    />
                  </View>
                </View>
              </>
            )}

            {step === "equipment" && (
              <>
                <Text style={styles.stepTitle}>What equipment do you have?</Text>
                <Text style={styles.helper}>
                  We&apos;ll recommend workouts that fit your gear. Pick all that apply.
                </Text>
                <View style={styles.eqGrid}>
                  {EQUIPMENT_OPTIONS.map((opt) => {
                    const active = equipment.includes(opt.id);
                    return (
                      <TouchableOpacity
                        key={opt.id}
                        onPress={() => toggleEquipment(opt.id)}
                        style={[
                          styles.eqTile,
                          active && {
                            backgroundColor: "#E4F7F2",
                            borderColor: ACCENT,
                          },
                        ]}
                        testID={`register-eq-${opt.id}`}
                        // @ts-ignore
                        data-testid={`register-eq-${opt.id}`}
                      >
                        <Text style={styles.eqEmoji}>{opt.emoji}</Text>
                        <Text
                          style={[
                            styles.eqLabel,
                            active && { color: ACCENT, fontWeight: "800" },
                          ]}
                        >
                          {opt.label}
                        </Text>
                        {active ? (
                          <View style={styles.eqCheck}>
                            <Check color="#FFFFFF" size={12} strokeWidth={3} />
                          </View>
                        ) : null}
                      </TouchableOpacity>
                    );
                  })}
                </View>
              </>
            )}

            {errorMsg ? <Text style={styles.error}>{errorMsg}</Text> : null}

            <View style={styles.btnRow}>
              {stepIndex > 0 ? (
                <TouchableOpacity
                  onPress={back}
                  style={styles.backBtn}
                  testID="register-back-button"
                  // @ts-ignore
                  data-testid="register-back-button"
                >
                  <ChevronLeft color={COLORS.text.secondary} size={18} />
                  <Text style={styles.backText}>Back</Text>
                </TouchableOpacity>
              ) : (
                <View style={{ flex: 1 }} />
              )}
              {stepIndex < 2 ? (
                <PrimaryButton
                  label="Continue"
                  color={ACCENT}
                  onPress={next}
                  style={{ flex: 1 }}
                  icon={<ChevronRight color="#FFFFFF" size={18} strokeWidth={2.5} />}
                  testID="register-next-button"
                />
              ) : (
                <PrimaryButton
                  label="Create Account"
                  color={ACCENT}
                  onPress={submit}
                  loading={loading}
                  style={{ flex: 1 }}
                  testID="register-submit-button"
                />
              )}
            </View>
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
    width: 80,
    height: 80,
    borderRadius: 40,
    alignSelf: "center",
    alignItems: "center",
    justifyContent: "center",
    marginTop: 4,
    marginBottom: 12,
    ...SHADOW_CARD,
  },
  title: {
    fontSize: 26,
    fontWeight: "800",
    color: COLORS.text.primary,
    textAlign: "center",
    letterSpacing: -0.6,
  },
  subtitle: {
    fontSize: 13,
    color: COLORS.text.tertiary,
    textAlign: "center",
    marginTop: 4,
    marginBottom: 16,
  },
  dotsRow: {
    flexDirection: "row",
    justifyContent: "center",
    gap: 6,
    marginBottom: 14,
  },
  dot: {
    width: 8,
    height: 8,
    borderRadius: 4,
    backgroundColor: "#D1D5DB",
  },
  card: { backgroundColor: COLORS.card, borderRadius: 20, padding: 20 },
  stepTitle: {
    color: COLORS.text.primary,
    fontSize: 16,
    fontWeight: "800",
    marginBottom: 12,
    letterSpacing: -0.3,
  },
  helper: { color: COLORS.text.tertiary, fontSize: 12, marginBottom: 12 },
  fieldLabel: {
    color: COLORS.text.secondary,
    fontSize: 13,
    fontWeight: "600",
    marginBottom: 6,
  },
  chipRow: { flexDirection: "row", gap: 8, marginBottom: 14 },
  chip: {
    flex: 1,
    paddingVertical: 10,
    borderRadius: 12,
    borderWidth: 1,
    borderColor: "#E5E7EB",
    backgroundColor: "#F3F6FA",
    alignItems: "center",
  },
  chipText: { color: COLORS.text.secondary, fontSize: 13, fontWeight: "700" },
  eqGrid: { flexDirection: "row", flexWrap: "wrap", gap: 8 },
  eqTile: {
    width: "31%",
    paddingVertical: 14,
    paddingHorizontal: 6,
    borderRadius: 14,
    borderWidth: 1,
    borderColor: "#E5E7EB",
    backgroundColor: "#F3F6FA",
    alignItems: "center",
    position: "relative",
  },
  eqEmoji: { fontSize: 22 },
  eqLabel: {
    color: COLORS.text.secondary,
    fontSize: 11,
    fontWeight: "700",
    marginTop: 6,
    textAlign: "center",
  },
  eqCheck: {
    position: "absolute",
    top: 6,
    right: 6,
    width: 18,
    height: 18,
    borderRadius: 9,
    backgroundColor: ACCENT,
    alignItems: "center",
    justifyContent: "center",
  },
  error: { color: "#DC2626", fontSize: 13, marginTop: 6, textAlign: "center" },
  btnRow: {
    flexDirection: "row",
    gap: 10,
    alignItems: "center",
    marginTop: 16,
  },
  backBtn: {
    flexDirection: "row",
    alignItems: "center",
    paddingVertical: 12,
    paddingHorizontal: 14,
    borderRadius: 18,
    backgroundColor: "#F3F6FA",
  },
  backText: { color: COLORS.text.secondary, fontWeight: "700", fontSize: 14 },
  eyeBtn: { paddingHorizontal: 14, paddingVertical: 12 },
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
