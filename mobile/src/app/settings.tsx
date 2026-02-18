import React, { useCallback, useEffect, useMemo, useState } from "react";
import {
  Platform,
  Pressable,
  ScrollView,
  Switch,
  Text,
  useColorScheme,
  View,
} from "react-native";
import Slider from "@react-native-community/slider";
import { LinearGradient } from "expo-linear-gradient";
import * as Haptics from "expo-haptics";
import * as Speech from "expo-speech";
import {
  Globe2,
  Languages,
  Mic2,
  ScanSearch,
  SlidersHorizontal,
  Volume2,
} from "lucide-react-native";

import { GlassCard } from "@/components/GlassCard";
import { cn } from "@/lib/cn";
import { useTranslations } from "@/lib/i18n";
import type { AppLanguage } from "@/lib/i18n";
import { useNarratorStore } from "@/lib/narrator-store";

interface VoiceOption {
  identifier: string;
  name: string;
  language: string;
  quality?: string;
}

interface LanguageOption {
  code: string;
  label: string;
}

const IOS_NATIVE_LANGUAGES: LanguageOption[] = [
  { code: "en-US", label: "English (United States)" },
  { code: "en-GB", label: "English (United Kingdom)" },
  { code: "fr-FR", label: "French (France)" },
  { code: "fr-CA", label: "French (Canada)" },
  { code: "es-ES", label: "Spanish (Spain)" },
  { code: "de-DE", label: "German (Germany)" },
  { code: "it-IT", label: "Italian (Italy)" },
  { code: "ja-JP", label: "Japanese (Japan)" },
  { code: "ko-KR", label: "Korean (South Korea)" },
  { code: "pt-BR", label: "Portuguese (Brazil)" },
  { code: "zh-CN", label: "Chinese (Simplified)" },
];

export default function SettingsScreen() {
  const colorScheme = useColorScheme();
  const voiceSettings = useNarratorStore((state) => state.voiceSettings);
  const setVoiceSettings = useNarratorStore((state) => state.setVoiceSettings);
  const extractionSettings = useNarratorStore(
    (state) => state.extractionSettings,
  );
  const setExtractionSettings = useNarratorStore(
    (state) => state.setExtractionSettings,
  );

  const [availableVoices, setAvailableVoices] = useState<VoiceOption[]>([]);
  const [isLoadingVoices, setIsLoadingVoices] = useState<boolean>(true);

  const t = useTranslations(voiceSettings.appLanguage);

  const appLanguages = useMemo<{ label: string; value: AppLanguage }[]>(
    () => [
      { label: t.english, value: "en" },
      { label: t.frenchFrance, value: "fr-FR" },
      { label: t.frenchCanadian, value: "fr-CA" },
    ],
    [t.english, t.frenchCanadian, t.frenchFrance],
  );

  const loadVoices = useCallback(async () => {
    setIsLoadingVoices(true);

    if (Platform.OS !== "ios") {
      setAvailableVoices([]);
      setIsLoadingVoices(false);
      return;
    }

    try {
      const voices = await Speech.getAvailableVoicesAsync();
      setAvailableVoices(voices);
    } catch (error) {
      console.error("Unable to load native voices", error);
      setAvailableVoices([]);
    } finally {
      setIsLoadingVoices(false);
    }
  }, []);

  useEffect(() => {
    loadVoices();
  }, [loadVoices]);

  const supportedNativeLanguages = useMemo<LanguageOption[]>(() => {
    if (availableVoices.length === 0) {
      return IOS_NATIVE_LANGUAGES;
    }

    const supportedCodes = new Set(
      availableVoices.map((voice) => voice.language),
    );
    return IOS_NATIVE_LANGUAGES.filter((language) =>
      supportedCodes.has(language.code),
    );
  }, [availableVoices]);

  useEffect(() => {
    if (supportedNativeLanguages.length === 0) {
      return;
    }

    const languageStillSupported = supportedNativeLanguages.some(
      (language) => language.code === voiceSettings.language,
    );

    if (!languageStillSupported) {
      setVoiceSettings({
        language: supportedNativeLanguages[0].code,
        voice: undefined,
      });
    }
  }, [setVoiceSettings, supportedNativeLanguages, voiceSettings.language]);

  const voicesForSelectedLanguage = useMemo<VoiceOption[]>(
    () =>
      availableVoices.filter(
        (voice) => voice.language === voiceSettings.language,
      ),
    [availableVoices, voiceSettings.language],
  );

  const selectedLanguageLabel =
    supportedNativeLanguages.find(
      (language) => language.code === voiceSettings.language,
    )?.label ?? voiceSettings.language;

  const onRunVoicePreview = () => {
    const preview =
      voiceSettings.language === "fr-CA" || voiceSettings.language === "fr-FR"
        ? "Bonjour! Ceci est un aperçu de votre voix native iOS."
        : "Hello! This is a preview of your native iOS voice.";

    Speech.stop();
    Speech.speak(preview, {
      language: voiceSettings.language,
      voice: voiceSettings.voice,
      pitch: voiceSettings.pitch,
      rate: voiceSettings.rate,
      volume: voiceSettings.volume,
    });
    Haptics.impactAsync(Haptics.ImpactFeedbackStyle.Medium);
  };

  const onSelectLanguage = (languageCode: string) => {
    const firstVoice = availableVoices.find(
      (voice) => voice.language === languageCode,
    );
    setVoiceSettings({
      language: languageCode,
      voice: firstVoice?.identifier,
      ttsProvider: "expo-speech",
    });
    Haptics.selectionAsync();
  };

  const onSelectVoice = (identifier: string) => {
    setVoiceSettings({ voice: identifier, ttsProvider: "expo-speech" });
    Haptics.selectionAsync();
  };

  return (
    <View className="flex-1">
      <LinearGradient
        colors={
          colorScheme === "dark"
            ? ["#0a0f1f", "#111827", "#0b1020"]
            : ["#edf4ff", "#f4f7ff", "#ffffff"]
        }
        style={{ flex: 1 }}
      >
        <ScrollView
          className="flex-1"
          contentContainerClassName="p-6 pb-28"
          showsVerticalScrollIndicator={false}
        >
          <View className="mt-3 mb-6">
            <Text
              className={cn(
                "text-3xl font-bold",
                colorScheme === "dark" ? "text-white" : "text-slate-900",
              )}
            >
              {t.settings}
            </Text>
            <Text
              className={cn(
                "mt-2 text-sm",
                colorScheme === "dark" ? "text-slate-300" : "text-slate-600",
              )}
            >
              {t.nativeSpeechSettingsDescription}
            </Text>
          </View>

          <GlassCard className="mb-5 p-5">
            <View className="mb-4 flex-row items-center gap-2">
              <Globe2
                size={20}
                color={colorScheme === "dark" ? "#fff" : "#0f172a"}
              />
              <Text
                className={cn(
                  "text-lg font-semibold",
                  colorScheme === "dark" ? "text-white" : "text-slate-900",
                )}
              >
                {t.appLanguage}
              </Text>
            </View>
            <View className="flex-row flex-wrap gap-2">
              {appLanguages.map((language) => (
                <Pressable
                  key={language.value}
                  onPress={() =>
                    setVoiceSettings({ appLanguage: language.value })
                  }
                  className={cn(
                    "rounded-full px-4 py-2",
                    voiceSettings.appLanguage === language.value
                      ? "bg-blue-600"
                      : colorScheme === "dark"
                        ? "bg-white/10"
                        : "bg-slate-200",
                  )}
                >
                  <Text
                    className={cn(
                      "text-xs font-semibold",
                      voiceSettings.appLanguage === language.value
                        ? "text-white"
                        : colorScheme === "dark"
                          ? "text-slate-100"
                          : "text-slate-700",
                    )}
                  >
                    {language.label}
                  </Text>
                </Pressable>
              ))}
            </View>
          </GlassCard>

          <GlassCard className="mb-5 p-5">
            <View className="mb-4 flex-row items-center gap-2">
              <Languages
                size={20}
                color={colorScheme === "dark" ? "#fff" : "#0f172a"}
              />
              <Text
                className={cn(
                  "text-lg font-semibold",
                  colorScheme === "dark" ? "text-white" : "text-slate-900",
                )}
              >
                {t.iosNativeLanguages}
              </Text>
            </View>

            <Text
              className={cn(
                "mb-3 text-xs",
                colorScheme === "dark" ? "text-slate-300" : "text-slate-600",
              )}
            >
              {t.currentLanguage}: {selectedLanguageLabel}
            </Text>

            <ScrollView
              horizontal
              showsHorizontalScrollIndicator={false}
              style={{ flexGrow: 0 }}
            >
              <View className="flex-row gap-2 pr-2">
                {supportedNativeLanguages.map((language) => (
                  <Pressable
                    key={language.code}
                    onPress={() => onSelectLanguage(language.code)}
                    className={cn(
                      "rounded-2xl px-4 py-2",
                      language.code === voiceSettings.language
                        ? "bg-blue-600"
                        : colorScheme === "dark"
                          ? "bg-white/10"
                          : "bg-slate-200",
                    )}
                  >
                    <Text
                      className={cn(
                        "text-xs font-semibold",
                        language.code === voiceSettings.language
                          ? "text-white"
                          : colorScheme === "dark"
                            ? "text-slate-100"
                            : "text-slate-700",
                      )}
                    >
                      {language.label}
                    </Text>
                  </Pressable>
                ))}
              </View>
            </ScrollView>
          </GlassCard>

          <GlassCard className="mb-5 p-5">
            <View className="mb-4 flex-row items-center gap-2">
              <Mic2
                size={20}
                color={colorScheme === "dark" ? "#fff" : "#0f172a"}
              />
              <Text
                className={cn(
                  "text-lg font-semibold",
                  colorScheme === "dark" ? "text-white" : "text-slate-900",
                )}
              >
                {t.nativeVoice}
              </Text>
            </View>

            {isLoadingVoices ? (
              <Text
                className={cn(
                  "text-sm",
                  colorScheme === "dark" ? "text-slate-300" : "text-slate-600",
                )}
              >
                {t.loadingNativeVoices}
              </Text>
            ) : voicesForSelectedLanguage.length === 0 ? (
              <Text
                className={cn(
                  "text-sm",
                  colorScheme === "dark" ? "text-slate-300" : "text-slate-600",
                )}
              >
                {t.noNativeVoiceAvailable}
              </Text>
            ) : (
              <View className="gap-2">
                {voicesForSelectedLanguage.map((voice) => (
                  <Pressable
                    key={voice.identifier}
                    onPress={() => onSelectVoice(voice.identifier)}
                    className={cn(
                      "rounded-2xl border px-4 py-3",
                      voiceSettings.voice === voice.identifier
                        ? "border-blue-500 bg-blue-600/20"
                        : colorScheme === "dark"
                          ? "border-white/10 bg-white/5"
                          : "border-slate-300 bg-slate-100",
                    )}
                  >
                    <Text
                      className={cn(
                        "text-sm font-semibold",
                        colorScheme === "dark"
                          ? "text-slate-100"
                          : "text-slate-800",
                      )}
                    >
                      {voice.name}
                    </Text>
                    <Text
                      className={cn(
                        "mt-1 text-xs",
                        colorScheme === "dark"
                          ? "text-slate-300"
                          : "text-slate-600",
                      )}
                    >
                      {voice.quality
                        ? `${voice.language} • ${voice.quality}`
                        : voice.language}
                    </Text>
                  </Pressable>
                ))}
              </View>
            )}
          </GlassCard>

          <GlassCard className="mb-5 p-5">
            <View className="mb-4 flex-row items-center gap-2">
              <SlidersHorizontal
                size={20}
                color={colorScheme === "dark" ? "#fff" : "#0f172a"}
              />
              <Text
                className={cn(
                  "text-lg font-semibold",
                  colorScheme === "dark" ? "text-white" : "text-slate-900",
                )}
              >
                {t.speechTuning}
              </Text>
            </View>

            <Text
              className={cn(
                "text-xs",
                colorScheme === "dark" ? "text-slate-300" : "text-slate-600",
              )}
            >
              {t.speed}: {voiceSettings.rate.toFixed(1)}x
            </Text>
            <Slider
              value={voiceSettings.rate}
              onValueChange={(value) => setVoiceSettings({ rate: value })}
              minimumValue={0.5}
              maximumValue={2}
              step={0.1}
              minimumTrackTintColor="#2563eb"
              maximumTrackTintColor={
                colorScheme === "dark" ? "#334155" : "#cbd5e1"
              }
              thumbTintColor="#2563eb"
            />

            <Text
              className={cn(
                "mt-3 text-xs",
                colorScheme === "dark" ? "text-slate-300" : "text-slate-600",
              )}
            >
              {t.pitch}: {voiceSettings.pitch.toFixed(1)}x
            </Text>
            <Slider
              value={voiceSettings.pitch}
              onValueChange={(value) => setVoiceSettings({ pitch: value })}
              minimumValue={0.5}
              maximumValue={2}
              step={0.1}
              minimumTrackTintColor="#2563eb"
              maximumTrackTintColor={
                colorScheme === "dark" ? "#334155" : "#cbd5e1"
              }
              thumbTintColor="#2563eb"
            />

            <View className="mt-3 flex-row items-center justify-between">
              <View>
                <Text
                  className={cn(
                    "text-xs",
                    colorScheme === "dark"
                      ? "text-slate-300"
                      : "text-slate-600",
                  )}
                >
                  {t.volume}: {Math.round(voiceSettings.volume * 100)}%
                </Text>
              </View>
              <Volume2
                size={18}
                color={colorScheme === "dark" ? "#fff" : "#0f172a"}
              />
            </View>
            <Slider
              value={voiceSettings.volume}
              onValueChange={(value) => setVoiceSettings({ volume: value })}
              minimumValue={0}
              maximumValue={1}
              step={0.05}
              minimumTrackTintColor="#2563eb"
              maximumTrackTintColor={
                colorScheme === "dark" ? "#334155" : "#cbd5e1"
              }
              thumbTintColor="#2563eb"
            />

            <Pressable
              onPress={onRunVoicePreview}
              className="mt-4 items-center rounded-xl bg-blue-600 px-4 py-3"
            >
              <Text className="text-sm font-semibold text-white">
                {t.testVoice}
              </Text>
            </Pressable>
          </GlassCard>

          <GlassCard className="mb-5 p-5">
            <View className="mb-4 flex-row items-center gap-2">
              <ScanSearch
                size={20}
                color={colorScheme === "dark" ? "#fff" : "#0f172a"}
              />
              <Text
                className={cn(
                  "text-lg font-semibold",
                  colorScheme === "dark" ? "text-white" : "text-slate-900",
                )}
              >
                {t.nativeIosHelpers}
              </Text>
            </View>

            <View className="mb-3 flex-row items-center justify-between">
              <View className="flex-1 pr-3">
                <Text
                  className={cn(
                    "text-sm font-semibold",
                    colorScheme === "dark"
                      ? "text-slate-100"
                      : "text-slate-800",
                  )}
                >
                  {t.clipboardMonitoring}
                </Text>
                <Text
                  className={cn(
                    "text-xs",
                    colorScheme === "dark"
                      ? "text-slate-300"
                      : "text-slate-600",
                  )}
                >
                  {t.clipboardNativeDescription}
                </Text>
              </View>
              <Switch
                value={extractionSettings.clipboardMonitoring}
                onValueChange={(value) =>
                  setExtractionSettings({ clipboardMonitoring: value })
                }
              />
            </View>

            <View className="flex-row items-center justify-between">
              <View className="flex-1 pr-3">
                <Text
                  className={cn(
                    "text-sm font-semibold",
                    colorScheme === "dark"
                      ? "text-slate-100"
                      : "text-slate-800",
                  )}
                >
                  {t.autoFetchWebContent}
                </Text>
                <Text
                  className={cn(
                    "text-xs",
                    colorScheme === "dark"
                      ? "text-slate-300"
                      : "text-slate-600",
                  )}
                >
                  {t.autoFetchNativeDescription}
                </Text>
              </View>
              <Switch
                value={extractionSettings.autoFetchURL}
                onValueChange={(value) =>
                  setExtractionSettings({ autoFetchURL: value })
                }
              />
            </View>

            <Text
              className={cn(
                "mt-4 text-xs",
                colorScheme === "dark" ? "text-slate-400" : "text-slate-500",
              )}
            >
              {t.runtimeLabel}:{" "}
              {Platform.OS === "ios" ? t.runtimeIosMode : t.runtimeFallbackMode}
            </Text>
          </GlassCard>
        </ScrollView>
      </LinearGradient>
    </View>
  );
}
