import Article from '../models/Article.js';

export async function listArticles(req, res) {
  const items = await Article.find({}).sort({ createdAt: -1 });
  res.json(items);
}
export async function getArticle(req, res) {
  const one = await Article.findById(req.params.id);
  if (!one) return res.status(404).json({ error: 'Not found' });
  res.json(one);
}
export async function createArticle(req, res) {
  const created = await Article.create(req.body);
  res.json(created);
}
export async function updateArticle(req, res) {
  const updated = await Article.findByIdAndUpdate(req.params.id, req.body, { new: true });
  res.json(updated);
}
export async function deleteArticle(req, res) {
  await Article.findByIdAndDelete(req.params.id);
  res.json({ ok: true });
}
