/*

    Copyright (c) 2025 Pocketz World. All rights reserved.

    This is a generated file, do not edit!

    Generated by com.pz.studio
*/

#if UNITY_EDITOR

using System;
using System.Linq;
using UnityEngine;
using Highrise.Client;
using Highrise.Studio;
using Highrise.Lua;

namespace Highrise.Lua.Generated
{
    [AddComponentMenu("Lua/BeeObjectManager")]
    [LuaRegisterType(0xefb7a8c7c43608c3, typeof(LuaBehaviour))]
    public class BeeObjectManager : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "40664b5e500bbe246afa9423ce9c9910";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_CommonBee = default;
        [SerializeField] public UnityEngine.GameObject m_StoneBee = default;
        [SerializeField] public UnityEngine.GameObject m_ForestBee = default;
        [SerializeField] public UnityEngine.GameObject m_AquaticBee = default;
        [SerializeField] public UnityEngine.GameObject m_GiantBee = default;
        [SerializeField] public UnityEngine.GameObject m_SilverBee = default;
        [SerializeField] public UnityEngine.GameObject m_MuddyBee = default;
        [SerializeField] public UnityEngine.GameObject m_FrigidBee = default;
        [SerializeField] public UnityEngine.GameObject m_SteelBee = default;
        [SerializeField] public UnityEngine.GameObject m_MagmaBee = default;
        [SerializeField] public UnityEngine.GameObject m_GhostlyBee = default;
        [SerializeField] public UnityEngine.GameObject m_IridescentBee = default;
        [SerializeField] public UnityEngine.GameObject m_SandyBee = default;
        [SerializeField] public UnityEngine.GameObject m_AutumnalBee = default;
        [SerializeField] public UnityEngine.GameObject m_PetalBee = default;
        [SerializeField] public UnityEngine.GameObject m_GalacticBee = default;
        [SerializeField] public UnityEngine.GameObject m_RadiantBee = default;
        [SerializeField] public UnityEngine.GameObject m_RainbowBee = default;
        [SerializeField] public UnityEngine.GameObject m_IndustrialBee = default;
        [SerializeField] public UnityEngine.GameObject m_HypnoticBee = default;
        [SerializeField] public UnityEngine.GameObject m_PearlescentBee = default;
        [SerializeField] public UnityEngine.GameObject m_AstralBee = default;
        [SerializeField] public UnityEngine.GameObject m_PrismaticBee = default;
        [SerializeField] public UnityEngine.GameObject m_ShadowBee = default;
        [SerializeField] public UnityEngine.GameObject m_MeadowBee = default;
        [SerializeField] public UnityEngine.GameObject m_BronzeBee = default;
        [SerializeField] public UnityEngine.GameObject m_OceanicBee = default;
        [SerializeField] public UnityEngine.GameObject m_RubyBee = default;
        [SerializeField] public UnityEngine.GameObject m_CamoBee = default;
        [SerializeField] public UnityEngine.GameObject m_CrystalBee = default;
        [SerializeField] public UnityEngine.GameObject m_TechnoBee = default;
        [SerializeField] public UnityEngine.GameObject m_PsychedelicBee = default;
        [SerializeField] public UnityEngine.GameObject m_FestiveBee = default;
        [SerializeField] public UnityEngine.GameObject m_RomanticBee = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_CommonBee),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_StoneBee),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_ForestBee),
                CreateSerializedProperty(_script.GetPropertyAt(3), m_AquaticBee),
                CreateSerializedProperty(_script.GetPropertyAt(4), m_GiantBee),
                CreateSerializedProperty(_script.GetPropertyAt(5), m_SilverBee),
                CreateSerializedProperty(_script.GetPropertyAt(6), m_MuddyBee),
                CreateSerializedProperty(_script.GetPropertyAt(7), m_FrigidBee),
                CreateSerializedProperty(_script.GetPropertyAt(8), m_SteelBee),
                CreateSerializedProperty(_script.GetPropertyAt(9), m_MagmaBee),
                CreateSerializedProperty(_script.GetPropertyAt(10), m_GhostlyBee),
                CreateSerializedProperty(_script.GetPropertyAt(11), m_IridescentBee),
                CreateSerializedProperty(_script.GetPropertyAt(12), m_SandyBee),
                CreateSerializedProperty(_script.GetPropertyAt(13), m_AutumnalBee),
                CreateSerializedProperty(_script.GetPropertyAt(14), m_PetalBee),
                CreateSerializedProperty(_script.GetPropertyAt(15), m_GalacticBee),
                CreateSerializedProperty(_script.GetPropertyAt(16), m_RadiantBee),
                CreateSerializedProperty(_script.GetPropertyAt(17), m_RainbowBee),
                CreateSerializedProperty(_script.GetPropertyAt(18), m_IndustrialBee),
                CreateSerializedProperty(_script.GetPropertyAt(19), m_HypnoticBee),
                CreateSerializedProperty(_script.GetPropertyAt(20), m_PearlescentBee),
                CreateSerializedProperty(_script.GetPropertyAt(21), m_AstralBee),
                CreateSerializedProperty(_script.GetPropertyAt(22), m_PrismaticBee),
                CreateSerializedProperty(_script.GetPropertyAt(23), m_ShadowBee),
                CreateSerializedProperty(_script.GetPropertyAt(24), m_MeadowBee),
                CreateSerializedProperty(_script.GetPropertyAt(25), m_BronzeBee),
                CreateSerializedProperty(_script.GetPropertyAt(26), m_OceanicBee),
                CreateSerializedProperty(_script.GetPropertyAt(27), m_RubyBee),
                CreateSerializedProperty(_script.GetPropertyAt(28), m_CamoBee),
                CreateSerializedProperty(_script.GetPropertyAt(29), m_CrystalBee),
                CreateSerializedProperty(_script.GetPropertyAt(30), m_TechnoBee),
                CreateSerializedProperty(_script.GetPropertyAt(31), m_PsychedelicBee),
                CreateSerializedProperty(_script.GetPropertyAt(32), m_FestiveBee),
                CreateSerializedProperty(_script.GetPropertyAt(33), m_RomanticBee),
            };
        }
    }
}

#endif
