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
    [AddComponentMenu("Lua/ObjectSpawnController")]
    [LuaRegisterType(0x1ddd6dd326ef1025, typeof(LuaBehaviour))]
    public class ObjectSpawnController : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "4c4fb7ad73ccad7479fedf3e3af8db5f";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_chair = default;
        [SerializeField] public UnityEngine.GameObject m_table = default;
        [SerializeField] public UnityEngine.GameObject m_chessTable = default;
        [SerializeField] public UnityEngine.GameObject m_bookTable = default;
        [SerializeField] public UnityEngine.GameObject m_whiteFlowerPlanter = default;
        [SerializeField] public UnityEngine.GameObject m_appleBox = default;
        [SerializeField] public UnityEngine.GameObject m_redMushroom = default;
        [SerializeField] public UnityEngine.GameObject m_brownMushroom = default;
        [SerializeField] public UnityEngine.GameObject m_teddyBear = default;
        [SerializeField] public UnityEngine.GameObject m_toyGoose = default;
        [SerializeField] public UnityEngine.GameObject m_pillow = default;
        [SerializeField] public UnityEngine.GameObject m_fountain = default;
        [SerializeField] public UnityEngine.GameObject m_flower_purple = default;
        [SerializeField] public UnityEngine.GameObject m_flower_red = default;
        [SerializeField] public UnityEngine.GameObject m_flower_white = default;
        [SerializeField] public UnityEngine.GameObject m_flower_yellow = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_chair),
                CreateSerializedProperty(_script.GetPropertyAt(1), m_table),
                CreateSerializedProperty(_script.GetPropertyAt(2), m_chessTable),
                CreateSerializedProperty(_script.GetPropertyAt(3), m_bookTable),
                CreateSerializedProperty(_script.GetPropertyAt(4), m_whiteFlowerPlanter),
                CreateSerializedProperty(_script.GetPropertyAt(5), m_appleBox),
                CreateSerializedProperty(_script.GetPropertyAt(6), m_redMushroom),
                CreateSerializedProperty(_script.GetPropertyAt(7), m_brownMushroom),
                CreateSerializedProperty(_script.GetPropertyAt(8), m_teddyBear),
                CreateSerializedProperty(_script.GetPropertyAt(9), m_toyGoose),
                CreateSerializedProperty(_script.GetPropertyAt(10), m_pillow),
                CreateSerializedProperty(_script.GetPropertyAt(11), m_fountain),
                CreateSerializedProperty(_script.GetPropertyAt(12), m_flower_purple),
                CreateSerializedProperty(_script.GetPropertyAt(13), m_flower_red),
                CreateSerializedProperty(_script.GetPropertyAt(14), m_flower_white),
                CreateSerializedProperty(_script.GetPropertyAt(15), m_flower_yellow),
            };
        }
    }
}

#endif
