import React, { useEffect, useState } from "react";
import {
  View,
  Text,
  StyleSheet,
  ScrollView,
  TouchableOpacity,
  KeyboardAvoidingView,
  Platform,
  Image,
  Alert,
} from "react-native";
import { SafeAreaView } from "react-native-safe-area-context";
import { useRouter } from "expo-router";
import * as ImagePicker from "expo-image-picker";
import { ArrowLeft, Camera, Calendar, Ruler, Scale, Check } from "lucide-react-native";

import { COLORS, SHADOW_CARD } from "@/src/constants/theme";
import { InputField } from "@/src/components/InputField";
import { DatePickerField } from "@/src/components/DatePickerField";
import { PrimaryButton } from "@/src/components/PrimaryButton";
import { useAuth } from "@/src/context/AuthContext";
import { saveProfile } from "@/src/services/db";
import {
  EQUIPMENT_OPTIONS,
  GENDER_OPTIONS,
  type EquipmentId,
} from "@/src/constants/equipment";

export default function EditProfile() {
  const router = useRouter();
  const { user, profile, refreshProfile } = useAuth();

  const [name, setName] = useState(profile?.name ?? "");
  const [gender, setGender] = useState(profile?.gender ?? "Female");
  const [dob, setDob] = useState(profile?.dob ?? "");
  const [height, setHeight] = useState(String(profile?.height ?? ""));
  const [weight, setWeight] = useState(String(profile?.weight ?? ""));
  const [equipment, setEquipment] = useState<EquipmentId[]>(profile?.equipment ?? ["bodyweight"]);
  const [photo, setPhoto] = useState<string | undefined>(profile?.photo);
  const [saving, setSaving] = useState(false);
  const [error, setError] = useState<string | null>(null);

  // Re-sync if profile loads after mount
  useEffect(() => {
    if (!profile) return;
    setName(profile.name ?? "");
    setGender(profile.gender ?? "Female");
    setDob(profile.dob ?? "");
    setHeight(String(profile.height ?? ""));
    setWeight(String(profile.weight ?? ""));
    setEquipment(profile.equipment ?? ["bodyweight"]);
    setPhoto(profile.photo);
  }, [profile?.uid]);

  const pickPhoto = async () => {
    try {
      const perm = await ImagePicker.requestMediaLibraryPermissionsAsync();
      if (!perm.granted) {
        Alert.alert("Permission needed", "Allow photo library access to update your profile picture.");
        return;
      }
      const result = await ImagePicker.launchImageLibraryAsync({
        mediaTypes: ImagePicker.MediaTypeOptions.Images,
        allowsEditing: true,
        aspect: [1, 1],
        quality: 0.5,
        base64: true,
      });
      if (result.canceled) return;
      const asset = result.assets?.[0];
      if (!asset?.base64) return;
      const dataUri = `data:image/jpeg;base64,${asset.base64}`;
      setPhoto(dataUri);
    } catch (e) {
      console.warn("pickPhoto", e);
    }
  };

  const toggleEquipment = (id: EquipmentId) =>
    setEquipment((prev) => (prev.includes(id) ? prev.filter((x) => x !== id) : [...prev, id]));

  const onSave = async () => {
    setError(null);
    if (!user) return;
    if (!name.trim()) return setError("Please enter your name.");
    const h = Number(height);
    const w = Number(weight);
    if (h && (h < 80 || h > 250)) return setError("Height must be 80–250 cm.");
    if (w && (w < 25 || w > 250)) return setError("Weight must be 25–250 kg.");
    setSaving(true);
    try {
      await saveProfile(user.uid, {
        name: name.trim(),
        gender,
        dob,
        height: h || undefined,
        weight: w || undefined,
        equipment,
        photo,
      });
      await refreshProfile();
      router.back();
    } catch (e: any) {
      setError(e?.message ?? "Could not save profile.");
    } finally {
      setSaving(false);
    }
  };

  return (
    <SafeAreaView style={styles.safe} edges={["top", "bottom"]}>
      <KeyboardAvoidingView
        behavior={Platform.OS === "ios" ? "padding" : undefined}
        style={{ flex: 1 }}
      >
        <View style={styles.header}>
          <TouchableOpacity
            onPress={() => router.back()}
            style={styles.backBtn}
            testID="edit-profile-back"
            // @ts-ignore
            data-testid="edit-profile-back"
          >
            <ArrowLeft color={COLORS.text.primary} size={20} strokeWidth={2.5} />
          </TouchableOpacity>
          <Text style={styles.headerTitle}>Edit Profile</Text>
          <View style={{ width: 40 }} />
        </View>

        <ScrollView contentContainerStyle={styles.scroll} keyboardShouldPersistTaps="handled">
          {/* Avatar */}
          <View style={styles.avatarWrap}>
            <TouchableOpacity
              onPress={pickPhoto}
              activeOpacity={0.8}
              testID="edit-profile-photo"
              // @ts-ignore
              data-testid="edit-profile-photo"
            >
              {photo ? (
                <Image source={{ uri: photo }} style={styles.avatarImg} />
              ) : (
                <View style={styles.avatarFallback}>
                  <Text style={styles.avatarInitial}>
                    {(name || "?").trim()[0]?.toUpperCase() ?? "?"}
                  </Text>
                </View>
              )}
              <View style={styles.cameraBadge}>
                <Camera color="#FFFFFF" size={16} strokeWidth={2.5} />
              </View>
            </TouchableOpacity>
            <Text style={styles.avatarHint}>Tap to change photo</Text>
          </View>

          <View style={[styles.card, SHADOW_CARD]}>
            <InputField
              label="Full Name"
              value={name}
              onChangeText={setName}
              testID="edit-profile-name"
            />
            <Text style={styles.fieldLabel}>Gender</Text>
            <View style={styles.chipRow}>
              {GENDER_OPTIONS.map((g) => (
                <TouchableOpacity
                  key={g}
                  onPress={() => setGender(g)}
                  style={[
                    styles.chip,
                    gender === g && { backgroundColor: COLORS.profile.avatar, borderColor: COLORS.profile.avatar },
                  ]}
                  testID={`edit-profile-gender-${g.toLowerCase()}`}
                  // @ts-ignore
                  data-testid={`edit-profile-gender-${g.toLowerCase()}`}
                >
                  <Text style={[styles.chipText, gender === g && { color: "#FFFFFF" }]}>{g}</Text>
                </TouchableOpacity>
              ))}
            </View>
            <DatePickerField
              label="Date of Birth"
              value={dob}
              onChange={(v) => setDob(v)}
              placeholder="Tap to pick your birthday"
              testID="edit-profile-dob"
            />
            <View style={{ flexDirection: "row", gap: 10 }}>
              <View style={{ flex: 1 }}>
                <InputField
                  label="Height (cm)"
                  icon={<Ruler color={COLORS.text.tertiary} size={18} />}
                  keyboardType="number-pad"
                  value={height}
                  onChangeText={setHeight}
                  testID="edit-profile-height"
                />
              </View>
              <View style={{ flex: 1 }}>
                <InputField
                  label="Weight (kg)"
                  icon={<Scale color={COLORS.text.tertiary} size={18} />}
                  keyboardType="decimal-pad"
                  value={weight}
                  onChangeText={setWeight}
                  testID="edit-profile-weight"
                />
              </View>
            </View>
          </View>

          <View style={[styles.card, SHADOW_CARD, { marginTop: 14 }]}>
            <Text style={styles.section}>Your Equipment</Text>
            <Text style={styles.helper}>Used to recommend workouts that match your gear.</Text>
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
                        backgroundColor: "#FBE3EE",
                        borderColor: COLORS.profile.avatar,
                      },
                    ]}
                    testID={`edit-profile-eq-${opt.id}`}
                    // @ts-ignore
                    data-testid={`edit-profile-eq-${opt.id}`}
                  >
                    <Text style={styles.eqEmoji}>{opt.emoji}</Text>
                    <Text
                      style={[
                        styles.eqLabel,
                        active && { color: COLORS.profile.avatar, fontWeight: "800" },
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
          </View>

          {error ? <Text style={styles.error}>{error}</Text> : null}

          <View style={{ marginTop: 18 }}>
            <PrimaryButton
              label="Save Changes"
              color={COLORS.profile.avatar}
              loading={saving}
              onPress={onSave}
              testID="edit-profile-save"
            />
          </View>
        </ScrollView>
      </KeyboardAvoidingView>
    </SafeAreaView>
  );
}

const styles = StyleSheet.create({
  safe: { flex: 1, backgroundColor: COLORS.background },
  header: {
    flexDirection: "row", alignItems: "center", justifyContent: "space-between",
    paddingHorizontal: 16, paddingVertical: 12,
  },
  backBtn: {
    width: 40, height: 40, borderRadius: 20, backgroundColor: COLORS.card,
    alignItems: "center", justifyContent: "center", ...SHADOW_CARD,
  },
  headerTitle: { color: COLORS.text.primary, fontSize: 18, fontWeight: "800", letterSpacing: -0.3 },
  scroll: { paddingHorizontal: 16, paddingBottom: 32 },
  avatarWrap: { alignItems: "center", marginTop: 4, marginBottom: 16 },
  avatarImg: { width: 110, height: 110, borderRadius: 55 },
  avatarFallback: {
    width: 110, height: 110, borderRadius: 55,
    backgroundColor: COLORS.profile.avatar,
    alignItems: "center", justifyContent: "center",
  },
  avatarInitial: { color: "#FFFFFF", fontSize: 44, fontWeight: "900" },
  cameraBadge: {
    position: "absolute", bottom: 0, right: 0,
    width: 34, height: 34, borderRadius: 17,
    backgroundColor: COLORS.primary,
    alignItems: "center", justifyContent: "center",
    borderWidth: 3, borderColor: "#FFFFFF",
  },
  avatarHint: { color: COLORS.text.tertiary, fontSize: 12, marginTop: 8, fontWeight: "600" },
  card: { backgroundColor: COLORS.card, borderRadius: 18, padding: 16 },
  section: { color: COLORS.text.primary, fontSize: 16, fontWeight: "800", letterSpacing: -0.3 },
  helper: { color: COLORS.text.tertiary, fontSize: 12, marginTop: 2, marginBottom: 12 },
  fieldLabel: { color: COLORS.text.secondary, fontSize: 13, fontWeight: "600", marginBottom: 6 },
  chipRow: { flexDirection: "row", gap: 8, marginBottom: 14 },
  chip: {
    flex: 1, paddingVertical: 10, borderRadius: 12,
    borderWidth: 1, borderColor: "#E5E7EB", backgroundColor: "#F3F6FA",
    alignItems: "center",
  },
  chipText: { color: COLORS.text.secondary, fontSize: 13, fontWeight: "700" },
  eqGrid: { flexDirection: "row", flexWrap: "wrap", gap: 8 },
  eqTile: {
    width: "31%", paddingVertical: 14, paddingHorizontal: 6, borderRadius: 14,
    borderWidth: 1, borderColor: "#E5E7EB", backgroundColor: "#F3F6FA",
    alignItems: "center", position: "relative",
  },
  eqEmoji: { fontSize: 22 },
  eqLabel: { color: COLORS.text.secondary, fontSize: 11, fontWeight: "700", marginTop: 6, textAlign: "center" },
  eqCheck: {
    position: "absolute", top: 6, right: 6,
    width: 18, height: 18, borderRadius: 9, backgroundColor: COLORS.profile.avatar,
    alignItems: "center", justifyContent: "center",
  },
  error: { color: "#DC2626", fontSize: 13, marginTop: 10, textAlign: "center" },
});
