'use client';
import { useEffect, useState } from 'react';
import AppShell from '@/components/layout/AppShell';
import api from '@/lib/api';
import {
  BarChart, Bar, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer,
  PieChart, Pie, Cell, LineChart, Line, Legend
} from 'recharts';
import { Bug, Users, Package, AlertTriangle, DollarSign, Activity } from 'lucide-react';

const COLORS = ['#6366f1', '#f59e0b', '#10b981', '#ef4444', '#8b5cf6', '#06b6d4'];

interface Stats {
  totals: {
    totalBugs: number;
    openBugs: number;
    totalEngineers: number;
    totalReleases: number;
    totalPenalties: number;
    totalPenaltyAmount: number;
  };
  bugsByStatus: { name: string; value: number }[];
  bugsByPriority: { name: string; value: number }[];
  recentBugs: { date: string; count: number }[];
}

function StatCard({ icon: Icon, title, value, color, subtitle }: any) {
  return (
    <div className="bg-gray-800 border border-gray-700 rounded-xl p-6">
      <div className="flex items-center justify-between mb-4">
        <div className={`w-10 h-10 ${color} rounded-lg flex items-center justify-center`}>
          <Icon className="w-5 h-5 text-white" />
        </div>
      </div>
      <p className="text-gray-400 text-sm">{title}</p>
      <p className="text-3xl font-bold text-white mt-1">{value}</p>
      {subtitle && <p className="text-xs text-gray-500 mt-1">{subtitle}</p>}
    </div>
  );
}

export default function DashboardPage() {
  const [stats, setStats] = useState<Stats | null>(null);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    api.get('/bugs/dashboard')
      .then((res) => setStats(res.data.data))
      .catch(console.error)
      .finally(() => setLoading(false));
  }, []);

  if (loading) {
    return (
      <AppShell>
        <div className="flex items-center justify-center h-full min-h-screen">
          <div className="text-white animate-pulse text-lg">Loading dashboard...</div>
        </div>
      </AppShell>
    );
  }

  const t = stats?.totals;

  return (
    <AppShell>
      <div className="p-8">
        <div className="mb-8">
          <h1 className="text-2xl font-bold text-white">Dashboard</h1>
          <p className="text-gray-400 mt-1">Overview of your software reliability operations</p>
        </div>

        {/* Stats Grid */}
        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-3 xl:grid-cols-6 gap-4 mb-8">
          <StatCard icon={Bug} title="Total Bugs" value={t?.totalBugs ?? 0} color="bg-indigo-600" />
          <StatCard icon={AlertTriangle} title="Open Bugs" value={t?.openBugs ?? 0} color="bg-red-500" subtitle="Needs attention" />
          <StatCard icon={Users} title="Engineers" value={t?.totalEngineers ?? 0} color="bg-emerald-600" />
          <StatCard icon={Package} title="Releases" value={t?.totalReleases ?? 0} color="bg-amber-500" />
          <StatCard icon={Activity} title="Penalties" value={t?.totalPenalties ?? 0} color="bg-purple-600" />
          <StatCard icon={DollarSign} title="Penalty Amount" value={`$${((t?.totalPenaltyAmount ?? 0)).toLocaleString()}`} color="bg-rose-600" />
        </div>

        {/* Charts */}
        <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
          {/* Bugs by Status */}
          <div className="bg-gray-800 border border-gray-700 rounded-xl p-6">
            <h2 className="text-white font-semibold mb-4">Bugs by Status</h2>
            <ResponsiveContainer width="100%" height={250}>
              <PieChart>
                <Pie
                  data={stats?.bugsByStatus}
                  cx="50%"
                  cy="50%"
                  innerRadius={60}
                  outerRadius={100}
                  paddingAngle={4}
                  dataKey="value"
                >
                  {stats?.bugsByStatus.map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Pie>
                <Tooltip
                  contentStyle={{ background: '#1f2937', border: '1px solid #374151', borderRadius: '8px', color: '#fff' }}
                />
                <Legend formatter={(value) => <span className="text-gray-300 text-sm">{value}</span>} />
              </PieChart>
            </ResponsiveContainer>
          </div>

          {/* Bugs by Priority */}
          <div className="bg-gray-800 border border-gray-700 rounded-xl p-6">
            <h2 className="text-white font-semibold mb-4">Bugs by Priority</h2>
            <ResponsiveContainer width="100%" height={250}>
              <BarChart data={stats?.bugsByPriority} barCategoryGap="30%">
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="name" tick={{ fill: '#9ca3af', fontSize: 12 }} />
                <YAxis tick={{ fill: '#9ca3af', fontSize: 12 }} allowDecimals={false} />
                <Tooltip
                  contentStyle={{ background: '#1f2937', border: '1px solid #374151', borderRadius: '8px', color: '#fff' }}
                />
                <Bar dataKey="value" name="Bugs" radius={[4, 4, 0, 0]}>
                  {stats?.bugsByPriority.map((_, i) => (
                    <Cell key={i} fill={COLORS[i % COLORS.length]} />
                  ))}
                </Bar>
              </BarChart>
            </ResponsiveContainer>
          </div>
        </div>

        {/* Recent Bugs Trend */}
        <div className="bg-gray-800 border border-gray-700 rounded-xl p-6">
          <h2 className="text-white font-semibold mb-4">Bug Reports (Last 30 Days)</h2>
          {stats?.recentBugs && stats.recentBugs.length > 0 ? (
            <ResponsiveContainer width="100%" height={250}>
              <LineChart data={stats.recentBugs}>
                <CartesianGrid strokeDasharray="3 3" stroke="#374151" />
                <XAxis dataKey="date" tick={{ fill: '#9ca3af', fontSize: 11 }} />
                <YAxis tick={{ fill: '#9ca3af', fontSize: 11 }} allowDecimals={false} />
                <Tooltip
                  contentStyle={{ background: '#1f2937', border: '1px solid #374151', borderRadius: '8px', color: '#fff' }}
                />
                <Line type="monotone" dataKey="count" stroke="#6366f1" strokeWidth={2} dot={{ fill: '#6366f1', r: 4 }} name="Bugs" />
              </LineChart>
            </ResponsiveContainer>
          ) : (
            <div className="h-64 flex items-center justify-center text-gray-500">
              No bug data in the last 30 days
            </div>
          )}
        </div>
      </div>
    </AppShell>
  );
}
