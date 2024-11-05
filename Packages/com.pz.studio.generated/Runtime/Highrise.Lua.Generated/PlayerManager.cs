/*

    Copyright (c) 2024 Pocketz World. All rights reserved.

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
    [AddComponentMenu("Lua/PlayerManager")]
    [LuaRegisterType(0xfe9baceb5f86083f, typeof(LuaBehaviour))]
    public class PlayerManager : LuaBehaviourThunk
    {
        private const string s_scriptGUID = "b93c2cc49bf171445a7b2dc17cc4ef4b";
        public override string ScriptGUID => s_scriptGUID;

        [SerializeField] public UnityEngine.GameObject m_playerStatObject = default;

        protected override SerializedPropertyValue[] SerializeProperties()
        {
            if (_script == null)
                return Array.Empty<SerializedPropertyValue>();

            return new SerializedPropertyValue[]
            {
                CreateSerializedProperty(_script.GetPropertyAt(0), m_playerStatObject),
            };
        }
    }
}

#endif
