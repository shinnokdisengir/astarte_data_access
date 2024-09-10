#
# This file is part of Astarte.
#
# Copyright 2024 SECO Mind Srl
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

defmodule Astarte.DataAccess.Realm.XandraTest do
  use ExUnit.Case
  alias Astarte.DataAccess.DatabaseTestHelper
  alias Astarte.DataAccess.Keyspace
  alias Astarte.DataAccess.XandraUtils
  alias Astarte.DataAccess.Realm

  @moduletag :realm

  @valid_realm_names [
    "realm1",
    "test",
    "testrealm1"
  ]

  @invalid_realm_names [
    "astarte",
    "123realm",
    "realm_123",
    "realm_####"
  ]

  setup do
    Xandra.Cluster.run(:astarte_data_access_xandra, fn conn ->
      DatabaseTestHelper.seed_data(conn)
    end)
  end

  setup_all do
    Xandra.Cluster.run(:astarte_data_access_xandra, fn conn ->
      DatabaseTestHelper.create_test_keyspace(conn)
    end)

    on_exit(fn ->
      Xandra.Cluster.run(:astarte_data_access_xandra, fn conn ->
        DatabaseTestHelper.destroy_local_test_keyspace(conn)
      end)
    end)

    :ok
  end

  describe "XandraUtils tests" do
    test "validate_realm_name/1" do
      for realm <- @valid_realm_names do
        assert :ok = XandraUtils.verify_realm_name(realm)
      end

      for realm <- @invalid_realm_names do
        assert {:error, :invalid_realm_name} = XandraUtils.verify_realm_name(realm)
      end
    end
  end

  describe "Realm tests" do
    test "keyspace_existing?/1" do
      assert {:ok, false} = Keyspace.keyspace_existing?("notexistingrealm")
    end

    test "create_realm & delete_realm" do
      assert :ok = Realm.create_realm("realm1", 1, "")
      assert :ok = Realm.delete_realm("realm1")
    end
  end
end
